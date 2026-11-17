import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_app/shared/overview_widgets.dart';
import '../security/security_controller.dart';

class AlarmSettingsPage extends ConsumerStatefulWidget {
  const AlarmSettingsPage({super.key});
  @override
  ConsumerState<AlarmSettingsPage> createState() => _AlarmSettingsPageState();
}

class _AlarmSettingsPageState extends ConsumerState<AlarmSettingsPage> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
        text: ref.read(securityControllerProvider).alarmName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverviewPage(
        title: 'Alarm Settings',
        subtitle: 'Personalise your local alarm interface.',
        child: OverviewPanel(
            title: 'Alarm name',
            icon: Icons.shield_outlined,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                  controller: controller,
                  maxLength: 60,
                  decoration: const InputDecoration(
                      labelText: 'Alarm name', filled: true)),
              const SizedBox(height: 16),
              const Text(
                  'This name is held in the current app session. Persistent configuration is not connected yet.'),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    ref
                        .read(securityControllerProvider.notifier)
                        .setAlarmName(controller.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text('Save')),
            ])),
      );
}
