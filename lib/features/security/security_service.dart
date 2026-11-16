import 'dart:async';
import 'security_model.dart';

class SecurityService {
  AlarmState state = AlarmState.unset;
  bool pendingSet = false;
  bool pendingUnset = false;

  bool _sensorActive = false; // simulate MINI-ZBD #2

  Function()? onStateChanged;

  Future<void> arm() async {
    pendingSet = true;
    state = AlarmState.setting;
    _notify();

    // simulate relay pulse + alarm set
    await Future.delayed(const Duration(seconds: 2));
    _sensorActive = true;
    pendingSet = false;
    state = AlarmState.set;
    _notify();
  }

  Future<void> disarm() async {
    pendingUnset = true;
    state = AlarmState.unsetting;
    _notify();

    // simulate relay pulse + alarm unset
    await Future.delayed(const Duration(seconds: 2));
    _sensorActive = false;
    pendingUnset = false;
    state = AlarmState.unset;
    _notify();
  }

  Future<SecurityModel> fetchStatus(SecurityModel current) async {
    // in real world, read MINI-ZBD #2 / RS485 here
    final active = _sensorActive;

    AlarmState newState;

    if (pendingSet) {
      newState = AlarmState.setting;
    } else if (pendingUnset) {
      newState = AlarmState.unsetting;
    } else {
      newState = active ? AlarmState.set : AlarmState.unset;
    }

    return current.copyWith(
      state: newState,
      alarmActive: active,
      pendingSet: pendingSet,
      pendingUnset: pendingUnset,
    );
  }

  void _notify() {
    if (onStateChanged != null) {
      onStateChanged!();
    }
  }
}
