import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/core/models/daily_energy.dart';
import 'package:nexus_app/core/models/nexus_energy_state.dart';
import 'package:nexus_app/core/providers/energy_provider.dart';
import 'package:nexus_app/core/repositories/energy_repository.dart';
import 'package:nexus_app/features/home/nexus_home.dart';
import 'package:nexus_app/features/home/widgets/nexus_energy_map.dart';
import 'package:nexus_app/theme/nexus_theme.dart';

class TestRepository extends NexusEnergyRepository {
  final pending = Completer<NexusEnergyState>();
  TestRepository() : super(baseUrl: '');
  @override
  Future<NexusEnergyState> fetchEnergyState() => pending.future;
  @override
  Future<DailyEnergy> fetchDailyTotals() => Completer<DailyEnergy>().future;
}

void main() {
  testWidgets('Connection failure retains navigation and offers retry', (
    tester,
  ) async {
    final repo = TestRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [energyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(theme: nexusTheme, home: const NexusHome()),
      ),
    );
    expect(find.text('Connecting to Nexus Core…'), findsOneWidget);
    repo.pending.completeError(Exception('Offline'));
    await tester.pump();
    expect(find.text('Unable to reach Nexus Core'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Security'), 200);
    expect(find.text('Security'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Live readings render on a narrow screen without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = TestRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [energyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(theme: nexusTheme, home: const NexusHome()),
      ),
    );
    repo.pending.complete(
      NexusEnergyState.fromJson({
        'gridDayKwh': 4.2,
        'solarDayKwh': 7.8,
        'homeDayKwh': 6.1,
      }),
    );
    await tester.pump();
    await tester.tap(find.byType(NexusEnergyMap));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Power now: 0.00 kW'), findsOneWidget);
    Navigator.of(tester.element(find.text('Power now: 0.00 kW'))).pop();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(find.text('4.2 kWh'), 200);
    expect(find.text('4.2 kWh'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
