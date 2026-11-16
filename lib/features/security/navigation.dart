import 'package:flutter/material.dart';
import 'security_overview.dart';
import 'notifications_page.dart';
import 'zones_page.dart';
import 'outputs_page.dart';

class TeslaNavigation extends StatefulWidget {
  const TeslaNavigation({super.key});

  @override
  State<TeslaNavigation> createState() => _TeslaNavigationState();
}

class _TeslaNavigationState extends State<TeslaNavigation> {
  int index = 0;

  final pages = const [
    SecurityOverview(),
    NotificationsPage(),
    ZonesPage(),
    OutputsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, anim) {
        return FadeTransition(opacity: anim, child: child);
      },
      child: pages[index],
    );
  }
}
