import 'package:flutter/material.dart';
import 'package:nexus_app/features/home/widgets/nexus_scaffold.dart';
import 'package:nexus_app/features/home/widgets/nexus_header.dart';
import 'tesla_security_map.dart';

enum AlarmState { unset, setting, set, unsetting }

class SecurityOverview extends StatefulWidget {
  const SecurityOverview({super.key});

  @override
  State<SecurityOverview> createState() => _SecurityOverviewState();
}

class _SecurityOverviewState extends State<SecurityOverview>
    with SingleTickerProviderStateMixin {
  AlarmState state = AlarmState.unset;
  int settingCountdown = 10;
  late AnimationController lockPulse;

  @override
  void initState() {
    super.initState();

    lockPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  void startSetting() {
    setState(() => state = AlarmState.setting);
    settingCountdown = 10;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (settingCountdown > 0) {
        setState(() => settingCountdown--);
        return true;
      }
      setState(() => state = AlarmState.set);
      return false;
    });
  }

  Color get homeColor {
    switch (state) {
      case AlarmState.unset:
        return Colors.green;
      case AlarmState.setting:
        return Colors.orange;
      case AlarmState.set:
        return Colors.red;
      case AlarmState.unsetting:
        return Colors.orange;
    }
  }

  IconData get lockIcon {
    switch (state) {
      case AlarmState.unset:
        return Icons.lock_open;
      case AlarmState.setting:
        return Icons.lock_clock;
      case AlarmState.set:
        return Icons.lock;
      case AlarmState.unsetting:
        return Icons.lock_open;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NexusScaffold(
      isMainPage: false,
      showSettings: true,

      child: SafeArea(
        child: Column(
          children: [
            // HEADER (same as EV)
            NexusHeader(
              isMainPage: false,
              onBack: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              title: "Security Overview",
              showSettings: true,
            ),

            const SizedBox(height: 20),

            // MAIN SECURITY NODE
            TeslaNode(
              radius: 70,
              color: homeColor,
              active: true,
              alert: false,
              badge: false,
              icon: lockIcon,
              label: state == AlarmState.setting
                  ? "Setting (${settingCountdown})"
                  : state == AlarmState.set
                      ? "SET"
                      : "UNSET",
              onTap: () {
                if (state == AlarmState.unset) startSetting();
                if (state == AlarmState.set) {
                  setState(() => state = AlarmState.unsetting);
                }
              },
            ),

            const SizedBox(height: 40),

            // GROUP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TeslaNode(
                  radius: 40,
                  color: Colors.blue,
                  active: false,
                  alert: false,
                  badge: false,
                  icon: Icons.shield,
                  label: "A1",
                  onTap: () {},
                ),
                const SizedBox(width: 40),
                TeslaNode(
                  radius: 40,
                  color: Colors.blue,
                  active: false,
                  alert: false,
                  badge: false,
                  icon: Icons.shield,
                  label: "A2",
                  onTap: () {},
                ),
                const SizedBox(width: 40),
                TeslaNode(
                  radius: 40,
                  color: Colors.blue,
                  active: false,
                  alert: false,
                  badge: false,
                  icon: Icons.shield,
                  label: "A3",
                  onTap: () {},
                ),
              ],
            ),

            const Spacer(),

            // BOTTOM NAVIGATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TeslaNode(
                  radius: 40,
                  color: Colors.white,
                  active: true,
                  alert: false,
                  badge: false,
                  icon: Icons.security,
                  label: "Security",
                  onTap: () {},
                ),
                TeslaNode(
                  radius: 40,
                  color: Colors.red,
                  active: false,
                  alert: false,
                  badge: true,
                  icon: Icons.notifications,
                  label: "Notifications",
                  onTap: () {},
                ),
                TeslaNode(
                  radius: 40,
                  color: Colors.red,
                  active: false,
                  alert: false,
                  badge: true,
                  icon: Icons.sensors,
                  label: "Zones",
                  onTap: () {},
                ),
                TeslaNode(
                  radius: 40,
                  color: Colors.blue,
                  active: false,
                  alert: false,
                  badge: false,
                  icon: Icons.power,
                  label: "Outputs",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
