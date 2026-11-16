class WaterStatus {
  final double flowLpm;
  final int batteryPercent;
  final bool valveOpen;
  final bool valveLocked;
  final String? lastUpdate;

  WaterStatus({
    required this.flowLpm,
    required this.batteryPercent,
    required this.valveOpen,
    required this.valveLocked,
    required this.lastUpdate,
  });

  factory WaterStatus.fromJson(Map<String, dynamic> json) {
    return WaterStatus(
      flowLpm: (json['flow_lpm'] ?? 0).toDouble(),
      batteryPercent: json['battery_percent'] ?? 100,
      valveOpen: json['valve_open'] ?? false,
      valveLocked: json['valve_locked'] ?? false,
      lastUpdate: json['last_update'],
    );
  }
}
