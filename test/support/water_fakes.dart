import 'dart:async';
import 'package:nexus_app/features/water/water_service.dart';
import 'package:nexus_app/features/water/water_status.dart';

class FakeWaterService extends WaterService {
  Map<String, dynamic> payload;
  bool online = true;
  bool accepted = true;
  final calls = <String>[];
  Completer<WaterStatus?>? statusGate;
  Completer<bool>? commandGate;
  FakeWaterService({Map<String, dynamic>? sample})
      : payload = sample ??
            {
              'flow_lpm': 1.8,
              'battery_percent': 80,
              'valve_open': false,
              'valve_locked': false,
              'last_update': '2026-11-17T10:00:00Z',
            },
        super('');
  @override
  Future<WaterStatus?> getStatus() async {
    if (statusGate != null) return await statusGate!.future;
    return online ? WaterStatus.fromJson(payload) : null;
  }

  Future<bool> change(String action, String field, bool value) async {
    calls.add(action);
    final success = commandGate != null ? await commandGate!.future : accepted;
    if (success) payload[field] = value;
    return success;
  }

  @override
  Future<bool> openValve() => change('open', 'valve_open', true);
  @override
  Future<bool> closeValve() => change('close', 'valve_open', false);
  @override
  Future<bool> lockValve() => change('lock', 'valve_locked', true);
  @override
  Future<bool> unlockValve() => change('unlock', 'valve_locked', false);
}
