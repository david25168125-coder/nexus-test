class WaterUsagePoint {
  final DateTime date;
  final double litres;
  const WaterUsagePoint({required this.date, required this.litres});
}

class WaterStatus {
  final double flowLpm;
  final int batteryPercent;
  final bool valveOpen;
  final bool valveLocked;
  final String? lastUpdate;
  final Set<String> reportedFields;
  final double? dailyLitres;
  final double? monthLitres;
  final double? yearLitres;
  final bool? leakDetected;
  final List<WaterUsagePoint> history;
  final List<String>? alerts;

  WaterStatus(
      {required this.flowLpm,
      required this.batteryPercent,
      required this.valveOpen,
      required this.valveLocked,
      required this.lastUpdate,
      this.reportedFields = const {
        'flow_lpm',
        'battery_percent',
        'valve_open',
        'valve_locked'
      },
      this.dailyLitres,
      this.monthLitres,
      this.yearLitres,
      this.leakDetected,
      this.history = const [],
      this.alerts});

  bool has(String field) => reportedFields.contains(field);
  static double? _number(dynamic value) {
    if (value is! num || !value.isFinite || value < 0) return null;
    return value.toDouble();
  }

  factory WaterStatus.fromJson(Map<String, dynamic> json) {
    final reported = <String>{};
    for (final key in ['flow_lpm', 'battery_percent']) {
      if (_number(json[key]) != null &&
          (key != 'battery_percent' || json[key] <= 100)) reported.add(key);
    }
    for (final key in ['valve_open', 'valve_locked']) {
      if (json[key] is bool) reported.add(key);
    }
    final history = <WaterUsagePoint>[];
    if (json['usage_history'] is List) {
      for (final entry in json['usage_history']) {
        if (entry is! Map) continue;
        final date =
            entry['date'] is String ? DateTime.tryParse(entry['date']) : null;
        final litres = _number(entry['liters']);
        if (date != null && litres != null)
          history.add(WaterUsagePoint(date: date, litres: litres));
      }
      history.sort((a, b) => a.date.compareTo(b.date));
    }
    return WaterStatus(
      flowLpm: _number(json['flow_lpm']) ?? 0,
      batteryPercent: (_number(json['battery_percent']) ?? 100).toInt(),
      valveOpen: json['valve_open'] == true,
      valveLocked: json['valve_locked'] == true,
      lastUpdate: json['last_update'] is String ? json['last_update'] : null,
      reportedFields: Set.unmodifiable(reported),
      dailyLitres: _number(json['daily_liters']),
      monthLitres: _number(json['month_liters']),
      yearLitres: _number(json['year_liters']),
      leakDetected:
          json['leak_detected'] is bool ? json['leak_detected'] : null,
      history: List.unmodifiable(history),
      alerts: json['alerts'] is List
          ? List<String>.unmodifiable(
              (json['alerts'] as List).whereType<String>())
          : null,
    );
  }
}
