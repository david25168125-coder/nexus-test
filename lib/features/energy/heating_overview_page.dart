import 'package:flutter/material.dart';
import 'package:nexus_app/shared/overview_widgets.dart';

class HeatingOverviewPage extends StatelessWidget {
  const HeatingOverviewPage({super.key});
  @override
  Widget build(BuildContext context) => OverviewPage(
        title: 'Heating',
        subtitle:
            'Comfort throughout your home. Heating data is not connected yet.',
        child: Column(children: [
          const OverviewPanel(
              title: 'Home climate',
              icon: Icons.thermostat_outlined,
              child: Wrap(spacing: 32, runSpacing: 24, children: [
                Reading('House temperature', '— °C',
                    detail: 'Awaiting a temperature sensor'),
                Reading('Heating state', 'Unavailable'),
                Reading('Energy today', '— kWh',
                    detail: 'Awaiting heating energy data'),
              ])),
          const SizedBox(height: 24),
          OverviewPanel(
              title: 'Zone temperatures',
              icon: Icons.meeting_room_outlined,
              child: Column(children: [
                const Text('Zone layout preview · no rooms are assigned yet.'),
                const SizedBox(height: 12),
                for (var i = 1; i <= 3; i++)
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.thermostat_outlined),
                      title: Text('Zone $i · unassigned'),
                      subtitle: const Text('Awaiting room sensor'),
                      trailing: const Text('— °C')),
              ])),
          const SizedBox(height: 24),
          const FutureFeature(
              title: 'Heating schedules',
              icon: Icons.schedule,
              description:
                  'No schedules are loaded. Local schedule management will appear here when the heating service is connected.'),
          const SizedBox(height: 24),
          const FutureFeature(
              title: 'Intelligent comfort',
              description:
                  'Future weather and occupancy recommendations will help balance comfort with energy use. No optimisation is active.'),
        ]),
      );
}
