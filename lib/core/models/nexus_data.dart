class NexusData {
  // -----------------------------
  // SOLAR
  // -----------------------------
  final double? solarKw;
  final bool? solarConnected;
  final bool? solarFault;

  // -----------------------------
  // GRID
  // -----------------------------
  final double? gridKw;
  final bool? gridConnected;
  final bool? gridFault;

  // Cheapest window (tariff)
  final bool? isCheapestWindow;

  // -----------------------------
  // BATTERY
  // -----------------------------
  final double? batteryKw;      // +ve = charging, -ve = discharging
  final double? batterySoc;     // %
  final bool? batteryConnected;
  final bool? batteryFault;

  // -----------------------------
  // HOME LOAD
  // -----------------------------
  final double? homeLoadKw;
  final bool? homeConnected;
  final bool? homeFault;

  // -----------------------------
  // EV
  // -----------------------------
  final double? evKw;           // charging power
  final double? evBattery;      // %
  final bool? evConnected;
  final bool? evFault;

  // -----------------------------
  // Constructor
  // -----------------------------
  const NexusData({
    this.solarKw,
    this.solarConnected,
    this.solarFault,
    this.gridKw,
    this.gridConnected,
    this.gridFault,
    this.isCheapestWindow,
    this.batteryKw,
    this.batterySoc,
    this.batteryConnected,
    this.batteryFault,
    this.homeLoadKw,
    this.homeConnected,
    this.homeFault,
    this.evKw,
    this.evBattery,
    this.evConnected,
    this.evFault,
  });

  // -----------------------------
  // EMPTY (safe defaults)
  // -----------------------------
  factory NexusData.empty() {
    return const NexusData(
      solarKw: 0,
      solarConnected: true,
      solarFault: false,
      gridKw: 0,
      gridConnected: true,
      gridFault: false,
      isCheapestWindow: false,
      batteryKw: 0,
      batterySoc: 50,
      batteryConnected: true,
      batteryFault: false,
      homeLoadKw: 0,
      homeConnected: true,
      homeFault: false,
      evKw: 0,
      evBattery: 50,
      evConnected: true,
      evFault: false,
    );
  }

  // -----------------------------
  // COPYWITH
  // -----------------------------
  NexusData copyWith({
    double? solarKw,
    bool? solarConnected,
    bool? solarFault,
    double? gridKw,
    bool? gridConnected,
    bool? gridFault,
    bool? isCheapestWindow,
    double? batteryKw,
    double? batterySoc,
    bool? batteryConnected,
    bool? batteryFault,
    double? homeLoadKw,
    bool? homeConnected,
    bool? homeFault,
    double? evKw,
    double? evBattery,
    bool? evConnected,
    bool? evFault,
  }) {
    return NexusData(
      solarKw: solarKw ?? this.solarKw,
      solarConnected: solarConnected ?? this.solarConnected,
      solarFault: solarFault ?? this.solarFault,
      gridKw: gridKw ?? this.gridKw,
      gridConnected: gridConnected ?? this.gridConnected,
      gridFault: gridFault ?? this.gridFault,
      isCheapestWindow: isCheapestWindow ?? this.isCheapestWindow,
      batteryKw: batteryKw ?? this.batteryKw,
      batterySoc: batterySoc ?? this.batterySoc,
      batteryConnected: batteryConnected ?? this.batteryConnected,
      batteryFault: batteryFault ?? this.batteryFault,
      homeLoadKw: homeLoadKw ?? this.homeLoadKw,
      homeConnected: homeConnected ?? this.homeConnected,
      homeFault: homeFault ?? this.homeFault,
      evKw: evKw ?? this.evKw,
      evBattery: evBattery ?? this.evBattery,
      evConnected: evConnected ?? this.evConnected,
      evFault: evFault ?? this.evFault,
    );
  }

  // -----------------------------
  // JSON SUPPORT
  // -----------------------------
  factory NexusData.fromJson(Map<String, dynamic> json) {
    return NexusData(
      solarKw: (json['solarKw'] ?? 0).toDouble(),
      solarConnected: json['solarConnected'] ?? true,
      solarFault: json['solarFault'] ?? false,
      gridKw: (json['gridKw'] ?? 0).toDouble(),
      gridConnected: json['gridConnected'] ?? true,
      gridFault: json['gridFault'] ?? false,
      isCheapestWindow: json['isCheapestWindow'] ?? false,
      batteryKw: (json['batteryKw'] ?? 0).toDouble(),
      batterySoc: (json['batterySoc'] ?? 50).toDouble(),
      batteryConnected: json['batteryConnected'] ?? true,
      batteryFault: json['batteryFault'] ?? false,
      homeLoadKw: (json['homeLoadKw'] ?? 0).toDouble(),
      homeConnected: json['homeConnected'] ?? true,
      homeFault: json['homeFault'] ?? false,
      evKw: (json['evKw'] ?? 0).toDouble(),
      evBattery: (json['evBattery'] ?? 50).toDouble(),
      evConnected: json['evConnected'] ?? true,
      evFault: json['evFault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solarKw': solarKw,
      'solarConnected': solarConnected,
      'solarFault': solarFault,
      'gridKw': gridKw,
      'gridConnected': gridConnected,
      'gridFault': gridFault,
      'isCheapestWindow': isCheapestWindow,
      'batteryKw': batteryKw,
      'batterySoc': batterySoc,
      'batteryConnected': batteryConnected,
      'batteryFault': batteryFault,
      'homeLoadKw': homeLoadKw,
      'homeConnected': homeConnected,
      'homeFault': homeFault,
      'evKw': evKw,
      'evBattery': evBattery,
      'evConnected': evConnected,
      'evFault': evFault,
    };
  }
}
