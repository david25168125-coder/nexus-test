import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus_app/core/providers/energy_provider.dart';

import 'widgets/nexus_scaffold.dart';
import 'widgets/nexus_energy_map.dart';

class NexusHome extends ConsumerWidget {
  const NexusHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return NexusScaffold(
      showSettings: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 56 : 24,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR HOME, CONNECTED',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      energy.when(
                        data: (_) =>
                            'Energy overview · Latest readings from Nexus Core',
                        loading: () => 'Connecting to Nexus Core…',
                        error: (_, __) => 'Energy readings unavailable',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: wide ? 480 : 400,
                      child: energy.when(
                        data: (data) => NexusEnergyMap(data: data),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sensors_off_rounded,
                                size: 40,
                                color: Color(0xFF9CA8B8),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Unable to reach Nexus Core',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Check your local connection, then try again.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    ref.read(energyProvider.notifier).refresh(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (energy.asData != null) ...[
                      const Divider(height: 48),
                      Wrap(
                        spacing: 48,
                        runSpacing: 24,
                        children: [
                          _Metric(
                            'Today’s grid energy',
                            '${energy.asData!.value.gridDayKwh.toStringAsFixed(1)} kWh',
                          ),
                          _Metric(
                            'Today’s solar',
                            '${energy.asData!.value.solarDayKwh.toStringAsFixed(1)} kWh',
                          ),
                          _Metric(
                            'Home consumption',
                            '${energy.asData!.value.homeDayKwh.toStringAsFixed(1)} kWh',
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                    Text(
                      'HOME CONTROLS',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _Control(
                          'Security',
                          Icons.shield_outlined,
                          '/security',
                        ),
                        _Control(
                          'EV charging',
                          Icons.ev_station_outlined,
                          '/ev',
                        ),
                        _Control('Water', Icons.water_drop_outlined, '/water'),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
      ],
    ),
  );
}

class _Control extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  const _Control(this.label, this.icon, this.route);

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => Navigator.pushNamed(context, route),
    icon: Icon(icon, size: 20),
    label: Text(label),
  );
}
