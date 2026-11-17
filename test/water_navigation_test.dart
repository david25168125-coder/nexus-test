import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/main.dart' show NexusApp;
import 'package:nexus_app/core/providers/energy_provider.dart';
import 'package:nexus_app/features/home/nexus_home.dart';
import 'package:nexus_app/features/settings/settings_page.dart';
import 'package:nexus_app/features/water/water_controller.dart';
import 'package:nexus_app/features/water/water_page.dart';
import 'package:nexus_app/features/water/water_status.dart';
import 'package:nexus_app/features/water/water_usage_chart.dart';
import 'package:nexus_app/shared/nexus_brand.dart';
import 'package:nexus_app/theme/nexus_theme.dart';
import 'support/energy_fakes.dart';
import 'support/water_fakes.dart';

Widget waterHarness(FakeWaterService service) => ProviderScope(
      overrides: [waterServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
          theme: nexusTheme,
          home: const WaterPage(),
          routes: {'/settings': (_) => const SettingsPage()}),
    );

Finder waterButton(String label) => find
    .ancestor(
        of: find.text(label),
        matching:
            find.byWidgetPredicate((widget) => widget is ButtonStyleButton))
    .first;

Future<void> frames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  test(
      'Legacy water data stays distinct from missing consumption and leak readings',
      () {
    final empty = WaterStatus.fromJson({});
    expect(empty.has('flow_lpm'), isFalse);
    expect(empty.has('valve_open'), isFalse);
    final zero = WaterStatus.fromJson(
        {'flow_lpm': 0, 'valve_open': false, 'valve_locked': false});
    expect(zero.has('flow_lpm'), isTrue);
    expect(zero.flowLpm, 0);
    expect(zero.dailyLitres, isNull);
    expect(zero.leakDetected, isNull);
    expect(zero.alerts, isNull);
    expect(zero.history, isEmpty);
    final invalid = WaterStatus.fromJson({
      'flow_lpm': -2,
      'battery_percent': 160,
      'daily_liters': -1,
      'usage_history': [
        {'date': 'bad', 'liters': 5}
      ]
    });
    expect(invalid.has('flow_lpm'), isFalse);
    expect(invalid.has('battery_percent'), isFalse);
    expect(invalid.dailyLitres, isNull);
    expect(invalid.history, isEmpty);
  });

  testWidgets('Water keeps all four valve actions and honours locking',
      (tester) async {
    final service = FakeWaterService();
    await tester.pumpWidget(waterHarness(service));
    await frames(tester);
    for (final action in ['Open valve', 'Close valve', 'Lock', 'Unlock']) {
      final button = waterButton(action);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await frames(tester);
      if (action == 'Lock') {
        expect(tester.widget<FilledButton>(waterButton('Open valve')).onPressed,
            isNull);
      }
    }
    expect(service.calls, ['open', 'close', 'lock', 'unlock']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Rejected valve request is reported without changing valve state',
      (tester) async {
    final service = FakeWaterService()..accepted = false;
    await tester.pumpWidget(waterHarness(service));
    await frames(tester);
    final button = waterButton('Open valve');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await frames(tester);
    expect(service.calls, ['open']);
    expect(service.payload['valve_open'], isFalse);
    expect(
        find.textContaining('valve request was not confirmed'), findsOneWidget);
    expect(find.text('Open valve'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'Water summaries use reported totals and history, not old sample usage',
      (tester) async {
    final service = FakeWaterService(sample: {
      'flow_lpm': 0,
      'battery_percent': 18,
      'valve_open': true,
      'valve_locked': false,
      'daily_liters': 112.4,
      'month_liters': 540.2,
      'year_liters': 1200,
      'leak_detected': true,
      'alerts': ['Inspect kitchen sensor'],
      'usage_history': [
        {'date': '2026-11-16', 'liters': 94},
        {'date': '2026-11-17', 'liters': 112.4}
      ],
    });
    await tester.pumpWidget(waterHarness(service));
    await frames(tester);
    expect(find.text('112.4 L'), findsNWidgets(2));
    expect(
        tester
            .widget<WaterUsageChart>(find.byType(WaterUsageChart))
            .history
            .length,
        2);
    expect(find.textContaining('Leak alert reported by Core'), findsOneWidget);
    expect(find.text('Inspect kitchen sensor'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Month'));
    await tester.pump();
    expect(find.text('540.2 L'), findsOneWidget);
    expect(find.text('12.4 L today'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'Offline refresh marks retained readings stale and disables valve controls',
      (tester) async {
    final service = FakeWaterService();
    await tester.pumpWidget(waterHarness(service));
    await frames(tester);
    service.online = false;
    final refresh = find.text('Refresh water status');
    await tester.ensureVisible(refresh);
    await tester.tap(refresh);
    await frames(tester);
    expect(find.text('Last known readings'), findsOneWidget);
    expect(find.textContaining('controls are paused'), findsOneWidget);
    expect(tester.widget<FilledButton>(waterButton('Open valve')).onPressed,
        isNull);
    expect(find.byTooltip('Dashboard'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('Controller prevents duplicate valve commands while one is in flight',
      () async {
    final service = FakeWaterService()..commandGate = Completer<bool>();
    final controller = WaterController(service);
    await controller.refresh();
    final first = controller.openValve();
    expect(await controller.openValve(), isFalse);
    expect(service.calls, ['open']);
    service.commandGate!.complete(true);
    expect(await first, isTrue);
    controller.dispose();
  });

  testWidgets(
      'Actual app routes and Settings sub-pages always provide Dashboard access',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final water = FakeWaterService()..online = false;
    await tester.pumpWidget(ProviderScope(overrides: [
      waterServiceProvider.overrideWithValue(water),
      energyRepositoryProvider.overrideWithValue(OverviewRepository()),
    ], child: const NexusApp()));
    await frames(tester);
    for (final route in [
      '/security',
      '/ev',
      '/water',
      '/solar',
      '/battery',
      '/heating',
      '/settings'
    ]) {
      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
      await frames(tester);
      expect(find.byType(NexusBrand), findsOneWidget);
      expect(find.byTooltip('Dashboard'), findsOneWidget);
      await tester.tap(find.byTooltip('Dashboard'));
      await frames(tester);
      expect(find.byType(NexusHome), findsOneWidget);
      expect(tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
          isFalse);
      expect(tester.takeException(), isNull, reason: route);
    }
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/settings');
    await frames(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Account'));
    await frames(tester);
    expect(find.byType(SettingDetailPage), findsOneWidget);
    await tester.tap(find.byTooltip('Dashboard'));
    await frames(tester);
    expect(find.byType(NexusHome), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('First-route Water can leave via Back while loading',
      (tester) async {
    final service = FakeWaterService()..statusGate = Completer<WaterStatus?>();
    await tester.pumpWidget(ProviderScope(
        overrides: [waterServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: nexusTheme,
          onGenerateInitialRoutes: (_) => [
            MaterialPageRoute(
                settings: const RouteSettings(name: '/water'),
                builder: (_) => const WaterPage())
          ],
          routes: {'/': (_) => const Scaffold(body: Text('Dashboard reached'))},
        )));
    await frames(tester);
    expect(find.byTooltip('Dashboard'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await frames(tester);
    expect(find.text('Dashboard reached'), findsOneWidget);
    service.statusGate!.complete(null);
    await tester.pumpWidget(const SizedBox());
  });
}
