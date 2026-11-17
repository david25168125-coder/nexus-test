import 'package:nexus_app/core/models/daily_energy.dart';
import 'package:nexus_app/core/models/nexus_energy_state.dart';
import 'package:nexus_app/core/repositories/energy_repository.dart';

class OverviewRepository extends NexusEnergyRepository {
  int pauses = 0;
  bool failPause = false;
  OverviewRepository() : super(baseUrl: '');
  @override
  Future<NexusEnergyState> fetchEnergyState() async =>
      NexusEnergyState.fromJson({
        'solarKw': 3.8,
        'solarDayKwh': 7.8,
        'batterySoc': 64,
        'batteryKw': -1.2,
        'evSoc': 72,
        'evKw': 2.4,
        'evDayKwh': 5.2,
      });
  @override
  Future<DailyEnergy> fetchDailyTotals() async => DailyEnergy.fromJson({
        'date': '2026-11-17',
        'grid_kwh': 1,
        'home_kwh': 2,
        'solar_kwh': 3,
        'battery_kwh': 4,
        'ev_kwh': 5,
      });
  @override
  Future<void> pauseCharging() async {
    pauses++;
    if (failPause) throw Exception('Charger unavailable');
  }
}

class SummaryRepository extends OverviewRepository {
  final Map<String, dynamic> sample;
  SummaryRepository(this.sample);
  @override
  Future<NexusEnergyState> fetchEnergyState() async =>
      NexusEnergyState.fromJson(sample);
}
