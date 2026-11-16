import 'package:flutter/material.dart';

import '../nexus_home.dart';

// Keep the existing dashboard entry point on the same home experience.
class NexusDashboard extends StatelessWidget {
  const NexusDashboard({super.key});

  @override
  Widget build(BuildContext context) => const NexusHome();
}
