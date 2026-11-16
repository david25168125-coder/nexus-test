import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_model.dart';
import 'security_service.dart';

final securityControllerProvider =
    StateNotifierProvider<SecurityController, SecurityModel>(
  (ref) => SecurityController(SecurityService()),
);

class SecurityController extends StateNotifier<SecurityModel> {
  final SecurityService service;
  Timer? _pollTimer;

  SecurityController(this.service)
      : super(SecurityModel.placeholder()) {
    service.onStateChanged = _syncFromService;
    _pollStatus();
  }

  void _pollStatus() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final updated = await service.fetchStatus(state);
      state = updated.copyWith(
        alarmName: state.alarmName,
        zones: state.zones,
      );
    });
  }

  void _syncFromService() {
    state = state.copyWith(
      state: service.state,
      pendingSet: service.pendingSet,
      pendingUnset: service.pendingUnset,
      alarmActive: state.alarmActive,
    );
  }

  Future<void> arm() async {
    await service.arm();
    _syncFromService();
  }

  Future<void> disarm() async {
    await service.disarm();
    _syncFromService();
  }

  void setAlarmName(String name) {
    state = state.copyWith(alarmName: name);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
