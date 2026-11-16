import 'package:flutter/foundation.dart';

/// Alarm state (matches your Python AlarmState)
enum AlarmState {
  unset,
  setting,
  set,
  unsetting,
  fault,
}

/// Zone model (RS485-ready, placeholder for now)
class SecurityZone {
  final String id;
  final String name;
  final bool open;
  final bool fault;
  final bool tamper;
  final bool bypassed;

  SecurityZone({
    required this.id,
    required this.name,
    required this.open,
    required this.fault,
    required this.tamper,
    required this.bypassed,
  });

  SecurityZone copyWith({
    String? id,
    String? name,
    bool? open,
    bool? fault,
    bool? tamper,
    bool? bypassed,
  }) {
    return SecurityZone(
      id: id ?? this.id,
      name: name ?? this.name,
      open: open ?? this.open,
      fault: fault ?? this.fault,
      tamper: tamper ?? this.tamper,
      bypassed: bypassed ?? this.bypassed,
    );
  }

  factory SecurityZone.placeholder({
    required String id,
    required String name,
    bool open = false,
  }) {
    return SecurityZone(
      id: id,
      name: name,
      open: open,
      fault: false,
      tamper: false,
      bypassed: false,
    );
  }
}

/// Full security system state
class SecurityModel {
  final AlarmState state;
  final bool alarmActive;
  final bool pendingSet;
  final bool pendingUnset;
  final List<SecurityZone> zones;

  final String alarmName;

  SecurityModel({
    required this.state,
    required this.alarmActive,
    required this.pendingSet,
    required this.pendingUnset,
    required this.zones,
    required this.alarmName,
  });

  SecurityModel copyWith({
    AlarmState? state,
    bool? alarmActive,
    bool? pendingSet,
    bool? pendingUnset,
    List<SecurityZone>? zones,
    String? alarmName,
  }) {
    return SecurityModel(
      state: state ?? this.state,
      alarmActive: alarmActive ?? this.alarmActive,
      pendingSet: pendingSet ?? this.pendingSet,
      pendingUnset: pendingUnset ?? this.pendingUnset,
      zones: zones ?? this.zones,
      alarmName: alarmName ?? this.alarmName,
    );
  }

  factory SecurityModel.placeholder() {
    return SecurityModel(
      state: AlarmState.unset,
      alarmActive: false,
      pendingSet: false,
      pendingUnset: false,
      zones: [
        SecurityZone.placeholder(id: "1", name: "Front Door"),
        SecurityZone.placeholder(id: "2", name: "Back Door", open: true),
        SecurityZone.placeholder(id: "3", name: "Living Room PIR"),
      ],
      alarmName: "Home Alarm",
    );
  }
}
