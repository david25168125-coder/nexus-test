import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/core/providers/energy_provider.dart';
import 'package:nexus_app/features/energy/energy_overview_page.dart';
import 'package:nexus_app/features/energy/heating_overview_page.dart';
import 'package:nexus_app/features/home/nexus_home.dart';
import 'package:nexus_app/features/home/widgets/tesla_energy_map.dart';
import 'package:nexus_app/features/security/screens/security_overview.dart';
import 'package:nexus_app/features/settings/settings_page.dart';
import 'package:nexus_app/features/settings/alarm_settings_page.dart';
import 'package:nexus_app/features/vehicle/screens/ev_overview.dart';
import 'package:nexus_app/theme/nexus_theme.dart';
import 'package:nexus_app/shared/overview_widgets.dart';
import 'package:nexus_app/features/water/water_page.dart';
import 'package:nexus_app/features/water/water_controller.dart';
import 'support/energy_fakes.dart';
import 'support/water_fakes.dart';

Widget harness(Widget page,
        {TargetPlatform platform = TargetPlatform.android,
        OverviewRepository? repository}) =>
    ProviderScope(
        overrides: [
          energyRepositoryProvider
              .overrideWithValue(repository ?? OverviewRepository()),
          waterServiceProvider.overrideWithValue(FakeWaterService())
        ],
        child: MaterialApp(
          theme: nexusTheme.copyWith(platform: platform),
          home: page,
          routes: {
            '/ev': (_) => const EVOverview(),
            '/settings': (_) => const SettingsPage(),
            '/solar': (_) => const EnergyOverviewPage(),
            '/battery': (_) => const EnergyOverviewPage(battery: true),
            '/heating': (_) => const HeatingOverviewPage(),
            '/water': (_) => const WaterPage(),
            '/security': (_) => const SecurityOverview()
          },
        ));

void main() {
  for (final spec in [
    (size: const Size(390, 844), platform: TargetPlatform.android),
    (size: const Size(480, 480), platform: TargetPlatform.android),
    (size: const Size(1280, 800), platform: TargetPlatform.android),
    (size: const Size(1440, 1000), platform: TargetPlatform.linux),
  ]) {
    testWidgets('Overviews fit ${spec.size} without overflow', (tester) async {
      tester.view.physicalSize = spec.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final page in [
        const SettingsPage(),
        const SecurityOverview(),
        const EVOverview(),
        const EnergyOverviewPage(),
        const EnergyOverviewPage(battery: true),
        const HeatingOverviewPage(),
        const WaterPage(),
      ]) {
        await tester.pumpWidget(harness(page, platform: spec.platform));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull,
            reason: '${page.runtimeType} at ${spec.size}');
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('Every settings destination opens a themed page', (tester) async {
    await tester.pumpWidget(harness(const SettingsPage()));
    for (final entry in settingsEntries) {
      final tile = find.widgetWithText(ListTile, entry.title);
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      if (entry.title == 'Alarm Settings') {
        expect(find.byType(AlarmSettingsPage), findsOneWidget);
      } else if (entry.title == 'Vehicle Overview') {
        expect(find.byType(EVOverview), findsOneWidget);
      } else {
        expect(find.byType(SettingDetailPage), findsOneWidget);
        expect(find.text(entry.description), findsOneWidget);
      }
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Alarm preview can arm and disarm using existing controller',
      (tester) async {
    await tester.pumpWidget(harness(const SecurityOverview()));
    expect(find.text('PREVIEW MODE · NO PHYSICAL ALARM CONNECTION'),
        findsOneWidget);
    expect(find.text('Disarmed'), findsOneWidget);
    await tester.ensureVisible(find.text('Preview arm'));
    await tester.tap(find.text('Preview arm'));
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();
    expect(find.text('Armed'), findsOneWidget);
    await tester.tap(find.text('Preview disarm'));
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();
    expect(find.text('Disarmed'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Failed EV command uses existing repository and keeps readings',
      (tester) async {
    final repo = OverviewRepository()..failPause = true;
    await tester.pumpWidget(harness(const EVOverview(), repository: repo));
    await tester.pump();
    final button = find.text('Pause charging');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump();
    expect(repo.pauses, 1);
    expect(find.textContaining('charger request could not be completed'),
        findsOneWidget);
    expect(find.text('72 %'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'Desktop nodes grow while tablet and phone node sizing stays unchanged',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final spec in [
      (
        size: const Size(1440, 1000),
        platform: TargetPlatform.linux,
        grows: true
      ),
      (
        size: const Size(1280, 800),
        platform: TargetPlatform.android,
        grows: false
      ),
      (size: const Size(390, 844), platform: TargetPlatform.iOS, grows: false),
    ]) {
      tester.view.physicalSize = spec.size;
      await tester
          .pumpWidget(harness(const NexusHome(), platform: spec.platform));
      await tester.pump();
      final map = tester.widget<TeslaEnergyMap>(find.byType(TeslaEnergyMap));
      expect(map.nodeScale, spec.grows ? greaterThan(1) : equals(1));
      expect(find.byType(Image), findsOneWidget, reason: 'One primary logo');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('Existing alarm-name setting updates the security overview',
      (tester) async {
    await tester.pumpWidget(harness(const SecurityOverview()));
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute(builder: (_) => const AlarmSettingsPage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Garden alarm');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Garden alarm'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'Overview summaries distinguish missing data from a reported zero',
      (tester) async {
    for (final sample in <Map<String, dynamic>>[
      {},
      {'solarKw': 0, 'solarDayKwh': 0}
    ]) {
      await tester.pumpWidget(harness(const EnergyOverviewPage(),
          repository: SummaryRepository(sample)));
      await tester.pump();
      final summary = find.widgetWithText(Reading, 'Generation now');
      expect(
          find.descendant(
              of: summary,
              matching: find.text(sample.isEmpty ? '— kW' : '0.00 kW')),
          findsOneWidget);
      final month = find.widgetWithText(Reading, 'This month');
      expect(find.descendant(of: month, matching: find.text('— kWh')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
