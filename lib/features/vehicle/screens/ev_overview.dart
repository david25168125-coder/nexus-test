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
    final batteryAvailable =
        data != null && has('evSoc') && data.evSoc >= 0 && data.evSoc <= 100;
    final battery = batteryAvailable ? '${data.evSoc} %' : '— %';
    final chargeStatus = data == null || !(has('evKw') || has('ev_kw'))
        ? 'Charging status unavailable'
        : data.evKw > 0.05
            ? 'Charging'
            : 'Not charging';
    final charging = data != null && data.evKw > 0.05;
    final summary =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Vehicle battery'),
      const SizedBox(height: 8),
      Text(battery,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 64,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFB0DBD1))),
      const SizedBox(height: 12),
      Semantics(
          label: batteryAvailable
              ? 'Battery ${data.evSoc} percent'
              : 'Battery reading unavailable',
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: batteryAvailable ? data.evSoc / 100 : 0,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF27333C)))),
      const SizedBox(height: 12),
      const Text(
          'Battery readings from Core · vehicle controls await a verified link.',
          style: TextStyle(fontSize: 12, color: Colors.white54)),
      const SizedBox(height: 24),
      Wrap(spacing: 28, runSpacing: 20, children: [
        const Reading('Estimated range', '— miles',
            detail: 'Range data not connected'),
        Reading(
            'Charging power',
            data == null || !(has('evKw') || has('ev_kw'))
                ? '— kW'
                : '${data.evKw.toStringAsFixed(2)} kW'),
      ]),
    ]);
    final hero = OverviewPanel(
        title: 'Vehicle overview',
        icon: Icons.directions_car_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            const StatusBadge('Vehicle link unavailable',
                icon: Icons.directions_car_outlined, color: Color(0xFF88ACDC)),
            StatusBadge(chargeStatus,
                icon: Icons.bolt_outlined,
                color: charging
                    ? const Color(0xFF81CBBE)
                    : const Color(0xFF88ACDC)),
          ]),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, bounds) {
            final wide = bounds.maxWidth >= 900;
            final vehicle = Column(children: [
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/systems/EV.jpg',
                          height: wide ? 340 : 220,
                          fit: BoxFit.contain,
                          semanticLabel: 'Vehicle illustration'))),
              const SizedBox(height: 10),
              const Text('Vehicle illustration',
                  style: TextStyle(fontSize: 12, color: Colors.white38)),
            ]);
            return wide
                ? Row(children: [
                    Expanded(flex: 3, child: vehicle),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: summary),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        summary,
                        const SizedBox(height: 24),
                        vehicle,
                      ]);
          }),
        ]));
    final controls = OverviewPanel(
        title: 'Charging controls',
        icon: Icons.ev_station_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(chargeStatus, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          const Text(
              'Commands are sent to your local Core. Your charger must be configured to use these controls.'),
          if (data == null)
            const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Connect to Core to use charging controls.')),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            FilledButton(
                onPressed: enabled
                    ? () => request(
                        'Fast charging', (repo) => repo.resumeFastCharging())
                    : null,
                child: const Text('Charge now')),
            OutlinedButton(
                onPressed: enabled
                    ? () => request('Pause', (repo) => repo.pauseCharging())
                    : null,
                child: const Text('Pause charging')),
            OutlinedButton(
                onPressed: enabled
                    ? () =>
                        request('Eco mode', (repo) => repo.resumeEcoCharging())
                    : null,
                child: const Text('Eco mode')),
          ]),
          if (busy)
            const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator()),
        ]));
    final climate = OverviewPanel(
        title: 'Climate',
        icon: Icons.ac_unit,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Wrap(spacing: 24, runSpacing: 20, children: [
            Reading('Cabin temperature', '— °C'),
            Reading('Target temperature', '— °C'),
          ]),
          const SizedBox(height: 20),
          const StatusBadge('Climate unavailable',
              icon: Icons.ac_unit, color: Color(0xFF88ACDC)),
          const SizedBox(height: 16),
          const Text(
              'Connect vehicle climate to pre-condition the cabin from Nexus. No remote climate command is available yet.'),
        ]));
    final schedules = OverviewPanel(
        title: 'Charging schedules',
        icon: Icons.schedule,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose a charging window that suits your day.'),
          const SizedBox(height: 12),
          const Text(
              'Existing schedules cannot yet be read back from Core on this screen.'),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            OutlinedButton(
                onPressed: enabled ? schedule : null,
                child: const Text('Set charging window')),
            TextButton(
                onPressed: enabled
                    ? () =>
                        request('Stop schedule', (repo) => repo.stopSchedule())
                    : null,
                child: const Text('Stop schedule')),
          ]),
        ]));
    final location = OverviewPanel(
        title: 'Vehicle location',
        icon: Icons.location_on_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const StatusBadge('Location unavailable',
              icon: Icons.location_off_outlined, color: Color(0xFF88ACDC)),
          const SizedBox(height: 20),
          Text('Your vehicle’s place in your day',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text(
              'Location and journey information will appear when a vehicle data source is configured. No position is being reported.'),
        ]));
    return OverviewPage(
        title: 'EV charging',
        subtitle: 'Vehicle, charging and battery status — at a glance.',
        child: Column(children: [
          hero,
          const SizedBox(height: 24),
          OverviewColumns(primary: controls, secondary: climate),
          const SizedBox(height: 24),
          OverviewColumns(primary: schedules, secondary: location),
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
        ]));
  }
}
