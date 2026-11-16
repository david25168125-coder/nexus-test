import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/core/providers/energy_controller.dart';
import 'package:nexus_app/core/repositories/energy_repository.dart';
import 'package:nexus_app/core/models/nexus_energy_state.dart'; // ✅ ADD THIS

// -------------------------
// REPOSITORY PROVIDER
// -------------------------
final energyRepositoryProvider = Provider<NexusEnergyRepository>((ref) {
  return NexusEnergyRepository(
    baseUrl: const String.fromEnvironment(
      'NEXUS_API_URL',
      defaultValue: 'http://127.0.0.1:8000',
    ),
  );
});

// -------------------------
// CONTROLLER PROVIDER
// -------------------------
final energyProvider =
    StateNotifierProvider<EnergyController, AsyncValue<NexusEnergyState>>((
      ref,
    ) {
      final repo = ref.watch(energyRepositoryProvider);
      return EnergyController(repo);
    });
