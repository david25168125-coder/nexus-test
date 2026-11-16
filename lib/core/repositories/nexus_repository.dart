import '../models/nexus_data.dart';
import '../services/haos_service.dart';
import '../services/mg_service.dart';
import '../services/sqlite_service.dart';
import '../services/scheduler_service.dart';

class NexusRepository {
  final HaosService haos;
  final MgService mg;
  final SqliteService db;
  final SchedulerService scheduler;

  NexusRepository({
    required this.haos,
    required this.mg,
    required this.db,
    required this.scheduler,
  });

  Future<NexusData> fetchData() async {
    try {
      final ev = await mg.getEvData();
      final solar = await haos.getSolarData();
      final grid = await haos.getGridData();
      final home = await haos.getHomeLoadData();

      return NexusData(
        evBattery: ev?.batteryPercent,
        solarKw: solar?.kw,
        gridKw: grid?.kw,
        homeLoadKw: home?.kw,
        isCharging: ev?.isCharging ?? false,
        isExporting: grid?.isExporting ?? false,
      );
    } catch (e) {
      return NexusData(error: e.toString());
    }
  }
}
