class NexusEnergyState {
  // -----------------------------
  // EXISTING FIELDS
  // -----------------------------
  final double solarKw;
  final double gridKw;
  final bool gridFault;
  final double homeLoadKw;
  final double batteryKw;
  final int batterySoc;
  final double evKw;
  final double evEnergyAddedKwh;
  final int evSoc;
  final Duration evTimeRemaining;

  final double solarDayKwh;
  final double solarMonthKwh;
  final double solarYearKwh;

  final double gridDayKwh;
  final double gridMonthKwh;
  final double gridYearKwh;

  final double homeDayKwh;
  final double homeMonthKwh;
  final double homeYearKwh;

  final double batteryDayKwh;
  final double batteryMonthKwh;
  final double batteryYearKwh;

  final double evDayKwh;
  final double evMonthKwh;
  final double evYearKwh;

  // -----------------------------
  // NEW DAILY TARIFF FIELDS
  // -----------------------------
  final double importTariffP;
  final double exportTariffP;

  // -----------------------------
  // NEW DAILY COST FIELD
  // -----------------------------
  final double dailyCost;

  // -----------------------------
  // NEW LIVE FIELDS
  // -----------------------------
  final double liveGridKw;
  final double liveHomeKw;
  final double liveEvKw;
  final double todayKwh;
  final String direction;

  // -----------------------------
  // NEW UI FIELDS (REQUIRED BY TESLA MAP)
  // -----------------------------
  final double homeKw;          // alias for homeLoadKw
  final bool solarComms;
  final bool batteryComms;
  final bool evComms;
  final bool gridComms;

  final bool solarFault;
  final bool batteryFault;
  final bool evFault;

  final int homeCostBand;

  const NexusEnergyState({
    // Existing
    required this.solarKw,
    required this.gridKw,
    required this.gridFault,
    required this.homeLoadKw,
    required this.batteryKw,
    required this.batterySoc,
    required this.evKw,
    required this.evEnergyAddedKwh,
    required this.evSoc,
    required this.evTimeRemaining,
    required this.solarDayKwh,
    required this.solarMonthKwh,
    required this.solarYearKwh,
    required this.gridDayKwh,
    required this.gridMonthKwh,
    required this.gridYearKwh,
    required this.homeDayKwh,
    required this.homeMonthKwh,
    required this.homeYearKwh,
    required this.batteryDayKwh,
    required this.batteryMonthKwh,
    required this.batteryYearKwh,
    required this.evDayKwh,
    required this.evMonthKwh,
    required this.evYearKwh,

    // New tariff fields
    required this.importTariffP,
    required this.exportTariffP,

    // New daily cost
    required this.dailyCost,

    // Live fields
    required this.liveGridKw,
    required this.liveHomeKw,
    required this.liveEvKw,
    required this.todayKwh,
    required this.direction,

    // New UI fields
    required this.homeKw,
    required this.solarComms,
    required this.batteryComms,
    required this.evComms,
    required this.gridComms,
    required this.solarFault,
    required this.batteryFault,
    required this.evFault,
    required this.homeCostBand,
  });

  factory NexusEnergyState.fromJson(Map<String, dynamic> json) {
    final importTariff = (json['importTariffP'] ?? 0).toDouble();
    final gridDay = (json['today_kwh'] ?? json['gridDayKwh'] ?? 0).toDouble();

    return NexusEnergyState(
      // Existing
      solarKw: (json['solarKw'] ?? 0).toDouble(),
      gridKw: (json['grid_kw'] ?? json['gridKw'] ?? 0).toDouble(),
      homeLoadKw: (json['home_kw'] ?? json['homeLoadKw'] ?? 0).toDouble(),
      evKw: (json['ev_kw'] ?? json['evKw'] ?? 0).toDouble(),
      gridFault: json['gridFault'] ?? false,
      batteryKw: (json['batteryKw'] ?? 0).toDouble(),
      batterySoc: (json['batterySoc'] ?? 0).toInt(),
      evEnergyAddedKwh: (json['evEnergyAddedKwh'] ?? 0).toDouble(),
      evSoc: (json['evSoc'] ?? 0).toInt(),
      evTimeRemaining: Duration(minutes: (json['evTimeRemainingMinutes'] ?? 0).toInt()),

      solarDayKwh: (json['solarDayKwh'] ?? 0).toDouble(),
      solarMonthKwh: (json['solarMonthKwh'] ?? 0).toDouble(),
      solarYearKwh: (json['solarYearKwh'] ?? 0).toDouble(),

      gridDayKwh: gridDay,
      gridMonthKwh: (json['gridMonthKwh'] ?? 0).toDouble(),
      gridYearKwh: (json['gridYearKwh'] ?? 0).toDouble(),

      homeDayKwh: (json['homeDayKwh'] ?? 0).toDouble(),
      homeMonthKwh: (json['homeMonthKwh'] ?? 0).toDouble(),
      homeYearKwh: (json['homeYearKwh'] ?? 0).toDouble(),

      batteryDayKwh: (json['batteryDayKwh'] ?? 0).toDouble(),
      batteryMonthKwh: (json['batteryMonthKwh'] ?? 0).toDouble(),
      batteryYearKwh: (json['batteryYearKwh'] ?? 0).toDouble(),

      evDayKwh: (json['evDayKwh'] ?? 0).toDouble(),
      evMonthKwh: (json['evMonthKwh'] ?? 0).toDouble(),
      evYearKwh: (json['evYearKwh'] ?? 0).toDouble(),

      // Tariffs
      importTariffP: importTariff,
      exportTariffP: (json['exportTariffP'] ?? 0).toDouble(),

      // Daily cost
      dailyCost: gridDay * (importTariff / 100),

      // Live fields
      liveGridKw: (json['grid_kw'] ?? 0).toDouble(),
      liveHomeKw: (json['home_kw'] ?? 0).toDouble(),
      liveEvKw: (json['ev_kw'] ?? 0).toDouble(),
      todayKwh: (json['today_kwh'] ?? 0).toDouble(),
      direction: json['direction'] ?? "unknown",

      // NEW UI FIELDS
      homeKw: (json['home_kw'] ?? json['homeLoadKw'] ?? 0).toDouble(),
      solarComms: true,
      batteryComms: true,
      evComms: true,
      gridComms: !(json['gridFault'] ?? false),
      solarFault: false,
      batteryFault: false,
      evFault: false,
      homeCostBand: 1,
    );
  }
}
