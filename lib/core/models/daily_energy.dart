class DailyEnergy {
  final String date;
  final double gridKwh;
  final double homeKwh;
  final double solarKwh;
  final double batteryKwh;
  final double evKwh;

  DailyEnergy({
    required this.date,
    required this.gridKwh,
    required this.homeKwh,
    required this.solarKwh,
    required this.batteryKwh,
    required this.evKwh,
  });

  factory DailyEnergy.fromJson(Map<String, dynamic> json) {
    return DailyEnergy(
      date: json['date'] ?? '',
      gridKwh: (json['grid_kwh'] ?? 0).toDouble(),
      homeKwh: (json['home_kwh'] ?? 0).toDouble(),
      solarKwh: (json['solar_kwh'] ?? 0).toDouble(),
      batteryKwh: (json['battery_kwh'] ?? 0).toDouble(),
      evKwh: (json['ev_kwh'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'grid_kwh': gridKwh,
      'home_kwh': homeKwh,
      'solar_kwh': solarKwh,
      'battery_kwh': batteryKwh,
      'ev_kwh': evKwh,
    };
  }
}
