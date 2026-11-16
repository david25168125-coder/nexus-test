import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus_app/theme/nexus_theme.dart';
import 'package:nexus_app/features/home/nexus_home.dart';

// NEW EV UI
import 'package:nexus_app/features/vehicle/screens/ev_overview.dart';

// WATER SYSTEM
import 'package:nexus_app/features/water/water_controller.dart';
import 'package:nexus_app/features/water/water_service.dart';
import 'package:nexus_app/features/water/water_page.dart';

// SECURITY SYSTEM
import 'package:nexus_app/features/security/screens/security_overview.dart';

// SETTINGS PAGE
import 'package:nexus_app/features/settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NexusApp()));
}

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Delay provider modification until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterControllerProvider.notifier).init();
    });

    return MaterialApp(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: nexusTheme,
      home: NexusHome(),

      routes: {

        // NEW EV UI (your new EV dashboard)
        '/ev': (context) => EVOverview(),

        // WATER SYSTEM
        '/water': (context) => WaterPage(),

        // SECURITY SYSTEM
        '/security': (context) => SecurityOverview(),

        // SETTINGS
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
