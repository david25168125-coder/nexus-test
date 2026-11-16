import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'water_service.dart';
import 'water_status.dart';

/// ------------------------------------------------------------
/// WATER STATE (immutable)
/// ------------------------------------------------------------
class WaterState {
  final bool loading;
  final WaterStatus? status;

  const WaterState({
    this.loading = false,
    this.status,
  });

  WaterState copyWith({
    bool? loading,
    WaterStatus? status,
  }) {
    return WaterState(
      loading: loading ?? this.loading,
      status: status ?? this.status,
    );
  }
}

/// ------------------------------------------------------------
/// WATER CONTROLLER (StateNotifier)
/// ------------------------------------------------------------
class WaterController extends StateNotifier<WaterState> {
  final WaterService service;

  WaterController(this.service) : super(const WaterState());

  /// Called from main.dart after provider is created
  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);

    final result = await service.getStatus();

    state = state.copyWith(
      loading: false,
      status: result,
    );
  }

  Future<void> openValve() async {
    await service.openValve();
    await refresh();
  }

  Future<void> closeValve() async {
    await service.closeValve();
    await refresh();
  }

  Future<void> lockValve() async {
    await service.lockValve();
    await refresh();
  }

  Future<void> unlockValve() async {
    await service.unlockValve();
    await refresh();
  }
}

/// ------------------------------------------------------------
/// RIVERPOD PROVIDERS
/// ------------------------------------------------------------

/// WaterService provider
final waterServiceProvider = Provider<WaterService>((ref) {
  return WaterService("http://127.0.0.1:8000");
});

/// WaterController provider
final waterControllerProvider =
    StateNotifierProvider<WaterController, WaterState>((ref) {
  final service = ref.watch(waterServiceProvider);
  return WaterController(service);
});
