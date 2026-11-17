import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/shared/overview_widgets.dart';
import 'water_controller.dart';
import 'water_usage_chart.dart';

class WaterPage extends ConsumerStatefulWidget {
  const WaterPage({super.key});
  @override
  ConsumerState<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends ConsumerState<WaterPage> {
  String usagePeriod = 'day';
  Timer? poll;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(waterControllerProvider.notifier).refresh();
    });
    poll = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && !ref.read(waterControllerProvider).commandPending) {
        ref.read(waterControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    poll?.cancel();
    super.dispose();
  }

  Future<void> action(Future<bool> Function() command) async {
    final accepted = await command();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(accepted
            ? 'Core accepted the request. Check the latest valve status.'
            : 'The valve request was not confirmed. Check the valve and local connection before retrying.')));
  }

  String litres(double? value) =>
      value == null ? '— L' : '${value.toStringAsFixed(1)} L';

  @override
  Widget build(BuildContext context) {
    final water = ref.watch(waterControllerProvider);
    final controller = ref.read(waterControllerProvider.notifier);
    final status = water.status;
    final stale = water.error != null && status != null;
    final ready = status != null &&
        !water.loading &&
        !water.commandPending &&
        water.error == null;
    final valveKnown = status?.has('valve_open') == true;
    final lockKnown = status?.has('valve_locked') == true;
    final valve = !valveKnown
        ? 'Valve unavailable'
        : status!.valveOpen
            ? 'Valve open'
            : 'Valve closed';
    final lock = !lockKnown
        ? 'Lock unavailable'
        : status!.valveLocked
            ? 'Locked'
            : 'Unlocked';
    final usage = switch (usagePeriod) {
      'month' => status?.monthLitres,
      'year' => status?.yearLitres,
      _ => status?.dailyLitres
    };
    final usageLabel = switch (usagePeriod) {
      'month' => 'This month’s consumption',
      'year' => 'This year’s consumption',
      _ => 'Today’s consumption'
    };
    final warnings = <String>[
      if (water.error != null) water.error!,
      if (status?.leakDetected == true)
        'Leak alert reported by Core. Check the water system.',
      if (status?.has('battery_percent') == true && status!.batteryPercent < 20)
        'Meter battery is low (${status.batteryPercent}%).',
      ...?status?.alerts,
    ];
    final hero = OverviewPanel(
        title: 'Water overview',
        icon: Icons.water_drop_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final period in [
              (label: 'Day', value: 'day'),
              (label: 'Month', value: 'month'),
              (label: 'Year', value: 'year')
            ])
              ChoiceChip(
                  label: Text(period.label),
                  selected: usagePeriod == period.value,
                  onSelected: (_) =>
                      setState(() => usagePeriod = period.value)),
          ]),
          const SizedBox(height: 24),
          OverviewColumns(
              primaryFlex: 3,
              secondaryFlex: 2,
              primary: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usageLabel),
                    const SizedBox(height: 10),
                    Text(litres(usage),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                                fontSize: 64,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -2,
                                color: const Color(0xFFA9C8ED))),
                    const SizedBox(height: 8),
                    Text(
                        usage == null
                            ? 'Consumption totals are not connected yet.'
                            : 'Consumption reported by Core.',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white54)),
                  ]),
              secondary: Wrap(spacing: 24, runSpacing: 24, children: [
                Reading(
                    'Current flow',
                    status?.has('flow_lpm') == true
                        ? '${status!.flowLpm.toStringAsFixed(1)} L/min'
                        : '— L/min'),
                Reading('Daily consumption', litres(status?.dailyLitres)),
              ])),
          const SizedBox(height: 24),
          Wrap(spacing: 10, runSpacing: 10, children: [
            StatusBadge(valve, icon: Icons.water_drop_outlined),
            StatusBadge(lock,
                icon: lockKnown && status!.valveLocked
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined),
            StatusBadge(
                stale
                    ? 'Last known readings'
                    : water.loading
                        ? 'Refreshing…'
                        : status == null
                            ? 'Core unavailable'
                            : 'Core response received',
                icon: stale ? Icons.history : Icons.sync,
                color:
                    stale ? const Color(0xFFFFBB80) : const Color(0xFF88ACDC)),
          ]),
        ]));
    final controls = OverviewPanel(
        title: 'Water controls',
        icon: Icons.tune,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(valve, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(lock),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            FilledButton.icon(
                onPressed:
                    ready && valveKnown && lockKnown && !status.valveLocked
                        ? () => action(status.valveOpen
                            ? controller.closeValve
                            : controller.openValve)
                        : null,
                icon: const Icon(Icons.water_drop_outlined),
                label: Text(valveKnown && status!.valveOpen
                    ? 'Close valve'
                    : 'Open valve')),
            OutlinedButton.icon(
                onPressed: ready && lockKnown
                    ? () => action(status.valveLocked
                        ? controller.unlockValve
                        : controller.lockValve)
                    : null,
                icon: const Icon(Icons.lock_outline),
                label:
                    Text(lockKnown && status!.valveLocked ? 'Unlock' : 'Lock')),
          ]),
          const SizedBox(height: 16),
          Text(lockKnown && status!.valveLocked
              ? 'Unlock the valve to change the water supply.'
              : 'Valve changes are sent to your local Core.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: water.loading || water.commandPending
                  ? null
                  : controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh water status')),
          if (water.loading || water.commandPending)
            const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator()),
        ]));
    return OverviewPage(
        title: 'Water',
        subtitle: 'Consumption, flow and supply — together in one place.',
        child: Column(children: [
          if (water.error != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                    stale
                        ? '${water.error!} Displaying last known readings; controls are paused.'
                        : water.error!,
                    style: const TextStyle(color: Color(0xFFFFBB80)))),
          hero,
          const SizedBox(height: 24),
          OverviewColumns(
              primaryFlex: 3,
              secondaryFlex: 2,
              primary: OverviewPanel(
                  title: 'Daily usage history',
                  icon: Icons.bar_chart,
                  child: WaterUsageChart(history: status?.history ?? const [])),
              secondary: controls),
          const SizedBox(height: 24),
          OverviewColumns(
              primary: OverviewPanel(
                  title: 'Leak detection',
                  icon: Icons.shield_outlined,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge(
                            status?.leakDetected == true
                                ? 'Leak alert reported'
                                : status?.leakDetected == false
                                    ? 'No leak reported'
                                    : 'Leak sensor not connected',
                            icon: status?.leakDetected == true
                                ? Icons.warning_amber
                                : Icons.sensors,
                            color: status?.leakDetected == true
                                ? const Color(0xFFFFBB80)
                                : const Color(0xFF88ACDC)),
                        const SizedBox(height: 16),
                        const Text(
                            'Leak status depends on a connected detection source. Zero flow alone does not confirm a leak-free system.'),
                        const SizedBox(height: 20),
                        const Text('Leak analytics',
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text(
                            'Unusual-use patterns and overnight monitoring will appear when meter history is available.'),
                      ])),
              secondary: OverviewPanel(
                  title: 'Alerts & meter status',
                  icon: Icons.notifications_outlined,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (warnings.isNotEmpty)
                          ...warnings.map((message) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(message,
                                  style: const TextStyle(
                                      color: Color(0xFFFFBB80)))))
                        else
                          Text(status?.alerts != null
                              ? 'No alerts reported in the latest response.'
                              : 'Alert history is not connected yet.'),
                        const Divider(height: 32),
                        Text(status?.has('battery_percent') == true
                            ? 'Meter battery: ${status!.batteryPercent}%'
                            : 'Meter battery: unavailable'),
                        const SizedBox(height: 10),
                        Text(status?.lastUpdate != null
                            ? 'Device update: ${status!.lastUpdate}'
                            : 'Device update time unavailable'),
                      ]))),
          const SizedBox(height: 24),
          const OverviewPanel(
              title: 'Smart meter ready',
              icon: Icons.speed,
              child: Text(
                  'Future meter integration will bring automatic consumption totals, richer history and usage insights into this view. Existing local valve controls remain available independently.')),
        ]));
  }
}
