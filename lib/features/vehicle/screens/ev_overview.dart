import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/core/providers/energy_provider.dart';
import 'package:nexus_app/core/repositories/energy_repository.dart';
import 'package:nexus_app/shared/overview_widgets.dart';

class EVOverview extends ConsumerStatefulWidget {
  const EVOverview({super.key});
  @override
  ConsumerState<EVOverview> createState() => _EVOverviewState();
}

class _EVOverviewState extends ConsumerState<EVOverview> {
  bool busy = false;

  Future<void> request(
      String label, Future<void> Function(NexusEnergyRepository) action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action(ref.read(energyRepositoryProvider))
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '$label request accepted by Core. Check the charger for confirmation.')));
      ref.read(energyProvider.notifier).refresh();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'The charger request could not be completed. Check your local connection and charger setup.')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> schedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final from = await showTimePicker(
        context: context,
        helpText: 'Charging starts',
        initialTime: const TimeOfDay(hour: 0, minute: 30));
    if (from == null || !mounted) return;
    final to = await showTimePicker(
        context: context,
        helpText: 'Charging ends',
        initialTime: const TimeOfDay(hour: 4, minute: 30));
    if (to == null || !mounted) return;
    final start =
        DateTime(date.year, date.month, date.day, from.hour, from.minute);
    var end = DateTime(date.year, date.month, date.day, to.hour, to.minute);
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1));
    if (!start.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Choose a charging start time in the future.')));
      return;
    }
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Charging schedule'),
              content: Text(
                  'Start: $start\nEnd: $end\n\nTimes use this device’s local time. Core must support charging schedules.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Send schedule'))
              ],
            ));
    if (confirmed == true && mounted)
      await request('Schedule', (repo) => repo.startSchedule(start, end));
  }

  @override
  Widget build(BuildContext context) {
    final energy = ref.watch(energyProvider);
    final data = energy.asData?.value;
    final enabled = data != null && !busy;
    bool has(String field) => data?.reportedFields.contains(field) == true;
    final battery = data != null && has('evSoc') ? '${data.evSoc} %' : '— %';
    final readings = Wrap(spacing: 32, runSpacing: 24, children: [
      Reading('Vehicle battery', battery,
          detail: 'Awaiting verified vehicle integration'),
      const Reading('Estimated range', '— miles',
          detail: 'Range data not connected'),
      Reading(
          'Charging power',
          data == null || !(has('evKw') || has('ev_kw'))
              ? '— kW'
              : '${data.evKw.toStringAsFixed(2)} kW',
          detail: 'Reported by Nexus Core'),
      Reading(
          'Charge status',
          data == null || !(has('evKw') || has('ev_kw'))
              ? 'Unavailable'
              : data.evKw > 0.05
                  ? 'Charging'
                  : 'Not charging',
          detail: 'Core reading · verify charger setup'),
    ]);
    return OverviewPage(
        title: 'EV charging',
        subtitle: 'Your vehicle, ready for the next journey.',
        child: Column(children: [
          OverviewPanel(
              title: 'Your vehicle',
              icon: Icons.directions_car_outlined,
              child: LayoutBuilder(builder: (context, bounds) {
                final vehicle = Column(children: [
                  Image.asset('assets/systems/EV.jpg',
                      height: 190,
                      fit: BoxFit.contain,
                      semanticLabel: 'Vehicle illustration'),
                  const Text('Vehicle illustration',
                      style: TextStyle(fontSize: 12, color: Colors.white38)),
                ]);
                return bounds.maxWidth >= 800
                    ? Row(children: [
                        Expanded(child: vehicle),
                        const SizedBox(width: 32),
                        Expanded(child: readings),
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            vehicle,
                            const SizedBox(height: 24),
                            readings
                          ]);
              })),
          const SizedBox(height: 24),
          OverviewPanel(
              title: 'Charging session',
              icon: Icons.bolt_outlined,
              child: Wrap(spacing: 32, runSpacing: 24, children: [
                Reading(
                    'Energy added',
                    data == null || !has('evEnergyAddedKwh')
                        ? '— kWh'
                        : '${data.evEnergyAddedKwh.toStringAsFixed(1)} kWh'),
                Reading(
                    'Charging today',
                    data == null || !has('evDayKwh')
                        ? '— kWh'
                        : '${data.evDayKwh.toStringAsFixed(1)} kWh'),
                Reading(
                    'Time remaining',
                    data != null && data.evTimeRemaining.inMinutes > 0
                        ? '${data.evTimeRemaining.inMinutes} min'
                        : 'Unavailable'),
              ])),
          const SizedBox(height: 24),
          OverviewPanel(
              title: 'Charging controls',
              icon: Icons.ev_station_outlined,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Controls use the existing local Core charger API. Your charger must be configured and support these commands.'),
                    if (data == null)
                      const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                              'Connect to Core to use charging controls.')),
                    const SizedBox(height: 20),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      FilledButton(
                          onPressed: enabled
                              ? () => request('Fast charging',
                                  (repo) => repo.resumeFastCharging())
                              : null,
                          child: const Text('Charge now')),
                      OutlinedButton(
                          onPressed: enabled
                              ? () => request(
                                  'Pause', (repo) => repo.pauseCharging())
                              : null,
                          child: const Text('Pause charging')),
                      OutlinedButton(
                          onPressed: enabled
                              ? () => request('Eco mode',
                                  (repo) => repo.resumeEcoCharging())
                              : null,
                          child: const Text('Eco mode')),
                    ]),
                    if (busy)
                      const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: LinearProgressIndicator()),
                  ])),
          const SizedBox(height: 24),
          OverviewPanel(
              title: 'Charging schedules',
              icon: Icons.schedule,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Choose a local charging window. Existing schedules cannot yet be read back from Core on this screen.'),
                    const SizedBox(height: 20),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      OutlinedButton(
                          onPressed: enabled ? schedule : null,
                          child: const Text('Set charging window')),
                      TextButton(
                          onPressed: enabled
                              ? () => request('Stop schedule',
                                  (repo) => repo.stopSchedule())
                              : null,
                          child: const Text('Stop schedule')),
                    ]),
                  ])),
          const SizedBox(height: 24),
          const FutureFeature(
              title: 'Vehicle details & comfort',
              icon: Icons.ac_unit,
              description:
                  'Vehicle documents, cabin climate, door status and driving efficiency will appear when your vehicle integration is connected.'),
        ]));
  }
}
