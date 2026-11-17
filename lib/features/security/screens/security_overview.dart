import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/shared/overview_widgets.dart';
import '../security_controller.dart';
import '../security_model.dart';

class SecurityOverview extends ConsumerWidget {
  const SecurityOverview({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarm = ref.watch(securityControllerProvider);
    final controller = ref.read(securityControllerProvider.notifier);
    final pending = alarm.pendingSet || alarm.pendingUnset;
    final status = switch (alarm.state) {
      AlarmState.unset => 'Disarmed',
      AlarmState.setting => 'Arming…',
      AlarmState.set => 'Armed',
      AlarmState.unsetting => 'Disarming…',
      AlarmState.fault => 'Needs attention',
    };
    return OverviewPage(
        title: 'Security',
        subtitle: 'Your alarm, doors and motion sensors in one place.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          OverviewPanel(
              title: alarm.alarmName,
              icon: Icons.shield_outlined,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PREVIEW MODE · NO PHYSICAL ALARM CONNECTION',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF88ACDC))),
                    const SizedBox(height: 20),
                    Row(children: [
                      Icon(
                          alarm.state == AlarmState.set
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          size: 56,
                          color: const Color(0xFF81CBBE)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Text(status,
                              style:
                                  Theme.of(context).textTheme.headlineLarge)),
                    ]),
                    const SizedBox(height: 16),
                    const Text(
                        'These controls preview the existing alarm behaviour. They do not secure or disarm your property.'),
                    const SizedBox(height: 24),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      FilledButton.icon(
                          onPressed: pending || alarm.state == AlarmState.set
                              ? null
                              : controller.arm,
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Preview arm')),
                      OutlinedButton.icon(
                          onPressed: pending || alarm.state == AlarmState.unset
                              ? null
                              : controller.disarm,
                          icon: const Icon(Icons.lock_open_outlined),
                          label: const Text('Preview disarm')),
                    ]),
                  ])),
          const SizedBox(height: 24),
          OverviewPanel(
              title: 'Doors & motion · preview zones',
              icon: Icons.sensors,
              child: Column(
                  children: alarm.zones.map((zone) {
                final motion = zone.name.toLowerCase().contains('pir');
                final state = zone.tamper
                    ? 'Tamper'
                    : zone.fault
                        ? 'Fault'
                        : zone.bypassed
                            ? 'Bypassed'
                            : zone.open
                                ? (motion ? 'Motion' : 'Open')
                                : (motion ? 'Clear' : 'Closed');
                return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(motion
                        ? Icons.sensors
                        : Icons.door_front_door_outlined),
                    title: Text(zone.name),
                    subtitle: Text('Zone ${zone.id} · preview data'),
                    trailing: Text(state,
                        style: TextStyle(
                            color: zone.open || zone.fault || zone.tamper
                                ? const Color(0xFFFFBB80)
                                : const Color(0xFF81CBBE))));
              }).toList())),
          const SizedBox(height: 24),
          const FutureFeature(
              title: 'Cameras',
              icon: Icons.videocam_outlined,
              description:
                  'No cameras are connected. Local camera thumbnails and full-screen viewing will appear here when configured.'),
          const SizedBox(height: 24),
          const FutureFeature(
              title: 'Activity & outputs',
              icon: Icons.history,
              description:
                  'Alarm events, notifications and connected output controls will appear when the security integration is connected.'),
        ]));
  }
}
