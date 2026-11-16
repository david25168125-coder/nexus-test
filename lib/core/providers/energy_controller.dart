import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/core/models/nexus_energy_state.dart';
import 'package:nexus_app/core/models/daily_energy.dart';
import 'package:nexus_app/core/repositories/energy_repository.dart';

class EnergyController extends StateNotifier<AsyncValue<NexusEnergyState>> {
  final NexusEnergyRepository repo;
  Timer? _timer;

  // NEW: daily totals state
  AsyncValue<DailyEnergy> daily = const AsyncValue.loading();

  EnergyController(this.repo) : super(const AsyncValue.loading()) {
    _startPolling();
  }

  // -------------------------
  // POLLING LOOP (every 5 seconds)
  // -------------------------
  void _startPolling() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await refresh();
      await refreshDaily();
    });

    // Initial fetch
    refresh();
    refreshDaily();
  }

  // -------------------------
  // REFRESH LIVE ENERGY STATE
  // -------------------------
  Future<void> refresh() async {
    try {
      final data = await repo.fetchEnergyState();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // -------------------------
  // REFRESH DAILY TOTALS
  // -------------------------
  Future<void> refreshDaily() async {
    try {
      final d = await repo.fetchDailyTotals();
      daily = AsyncValue.data(d);
    } catch (e, st) {
      daily = AsyncValue.error(e, st);
    }
  }

  // -------------------------
  // GRID ISOLATOR
  // -------------------------
  Future<void> toggleGridIsolator() async {
    try {
      await repo.toggleGridIsolator();
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // -------------------------
  // EV CONTROLS
  // -------------------------
  Future<void> pauseCharging() async {
    try {
      await repo.pauseCharging();
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resumeFastCharging() async {
    try {
      await repo.resumeFastCharging();
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resumeEcoCharging() async {
    try {
      await repo.resumeEcoCharging();
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // -------------------------
  // EV SCHEDULING
  // -------------------------
  Future<void> startSchedule(DateTime start, DateTime end) async {
    try {
      await repo.startSchedule(start, end);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> stopSchedule() async {
    try {
      await repo.stopSchedule();
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> finishBy(DateTime deadline, int targetSoc) async {
    try {
      await repo.finishBy(deadline, targetSoc);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
