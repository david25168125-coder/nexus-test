import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/core/providers/energy_provider.dart';
import 'package:nexus_app/shared/overview_widgets.dart';
import 'package:nexus_app/features/home/widgets/nexus_energy_map.dart';

class EnergyOverviewPage extends ConsumerWidget {
  final bool battery;
  const EnergyOverviewPage({super.key, this.battery = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyProvider);
    final data = energy.asData?.value;
    double? reported(String key, double? value) =>
        data?.reportedFields.contains(key) == true ? value : null;
    String power(double? value) =>
        value == null ? '— kW' : '${value.abs().toStringAsFixed(2)} kW';
    String total(double? value) =>
        value == null ? '— kWh' : '${value.toStringAsFixed(1)} kWh';
    return OverviewPage(
      title: battery ? 'Battery' : 'Solar',
      subtitle: energy.isLoading
          ? 'Connecting to Nexus Core…'
          : data == null
              ? 'Readings unavailable. Check your local Core connection.'
              : 'Core readings · equipment setup may be incomplete.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        OverviewPanel(
            title: battery ? 'Stored energy' : 'Generation overview',
            icon: battery
                ? Icons.battery_charging_full
                : Icons.solar_power_outlined,
            child: Wrap(
                spacing: 32,
                runSpacing: 24,
                children: battery
                    ? [
                        Reading(
                            'State of charge',
                            data?.reportedFields.contains('batterySoc') == true
                                ? '${data!.batterySoc} %'
                                : '— %',
                            detail: 'Reported by Nexus Core'),
                        Reading('Battery power',
                            power(reported('batteryKw', data?.batteryKw))),
                        Reading(
                            'Today’s usage',
                            total(reported(
                                'batteryDayKwh', data?.batteryDayKwh))),
                        Reading(
                            'Battery state',
                            data == null ||
                                    !data.reportedFields.contains('batteryKw')
                                ? 'Unavailable'
                                : data.batteryFault
                                    ? 'Check battery'
                                    : data.batteryKw > 0.05
                                        ? 'Charging'
                                        : data.batteryKw < -0.05
                                            ? 'Supplying home'
                                            : 'Idle'),
                      ]
                    : [
                        Reading('Generation now',
                            power(reported('solarKw', data?.solarKw))),
                        Reading('Daily production',
                            total(reported('solarDayKwh', data?.solarDayKwh))),
                        Reading(
                            'This month',
                            total(reported(
                                'solarMonthKwh', data?.solarMonthKwh))),
                        Reading(
                            'This year',
                            total(
                                reported('solarYearKwh', data?.solarYearKwh))),
                      ])),
        const SizedBox(height: 24),
        if (data != null)
          OverviewPanel(
              title: 'Energy flow',
              child: SizedBox(height: 420, child: NexusEnergyMap(data: data)))
        else
          const FutureFeature(
              title: 'Energy flow',
              icon: Icons.hub_outlined,
              description:
                  'Your energy connections will appear when readings are available from Nexus Core.'),
        const SizedBox(height: 24),
        FutureFeature(
            title: battery ? 'Battery optimisation' : 'Solar outlook',
            description: battery
                ? 'Future weather-aware charging, backup reserve and solar capacity planning. No automatic strategy is active.'
                : 'Future generation forecasts will combine weather and historical production. No forecast is available yet.'),
      ]),
    );
  }
}
