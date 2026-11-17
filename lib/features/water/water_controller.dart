import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'water_service.dart';
import 'water_status.dart';

class WaterState {
  final bool loading;
  final bool commandPending;
  final WaterStatus? status;
  final String? error;
  final DateTime? lastChecked;
  const WaterState(
      {this.loading = false,
      this.commandPending = false,
      this.status,
      this.error,
      this.lastChecked});
  WaterState copyWith(
          {bool? loading,
          bool? commandPending,
          WaterStatus? status,
          String? error,
          bool clearError = false,
          DateTime? lastChecked}) =>
      WaterState(
        loading: loading ?? this.loading,
        commandPending: commandPending ?? this.commandPending,
        status: status ?? this.status,
        error: clearError ? null : error ?? this.error,
        lastChecked: lastChecked ?? this.lastChecked,
      );
}

class WaterController extends StateNotifier<WaterState> {
  final WaterService service;
  WaterController(this.service) : super(const WaterState());
  Future<void> init() => refresh();

  Future<void> refresh() async {
    if (state.loading) return;
    state = state.copyWith(loading: true);
    try {
      final result = await service.getStatus();
      if (!mounted) return;
      state = result == null
          ? state.copyWith(
              loading: false,
              error:
                  'Water readings are unavailable. Check your local Core connection.')
          : state.copyWith(
              loading: false,
              status: result,
              clearError: true,
              lastChecked: DateTime.now());
    } catch (_) {
      if (mounted)
        state = state.copyWith(
            loading: false,
            error:
                'Water readings are unavailable. Check your local Core connection.');
    }
  }

  Future<bool> _command(Future<bool> Function() action) async {
    if (state.commandPending ||
        state.loading ||
        state.error != null ||
        state.status == null) return false;
    state = state.copyWith(commandPending: true);
    try {
      final accepted = await action();
      if (!mounted) return false;
      await refresh();
      return accepted;
    } catch (_) {
      return false;
    } finally {
      if (mounted) state = state.copyWith(commandPending: false);
    }
  }

  Future<bool> openValve() async {
    if (state.status?.has('valve_locked') != true || state.status!.valveLocked)
      return false;
    return _command(service.openValve);
  }

  Future<bool> closeValve() async {
    if (state.status?.has('valve_locked') != true || state.status!.valveLocked)
      return false;
    return _command(service.closeValve);
  }

  Future<bool> lockValve() => _command(service.lockValve);
  Future<bool> unlockValve() => _command(service.unlockValve);
}

final waterServiceProvider = Provider<WaterService>((ref) => WaterService(
    const String.fromEnvironment('NEXUS_API_URL',
        defaultValue: 'http://127.0.0.1:8000')));
final waterControllerProvider =
    StateNotifierProvider<WaterController, WaterState>(
        (ref) => WaterController(ref.watch(waterServiceProvider)));
