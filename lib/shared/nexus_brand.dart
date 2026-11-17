import 'package:flutter/material.dart';

/// The logo supplied in Settings is the single application brand asset.
class NexusBrand extends StatelessWidget {
  final double size;
  const NexusBrand({super.key, this.size = 36});
  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/digitize_nexus_logo.png',
        width: size,
        height: size,
        semanticLabel: 'Nexus',
      );
}

bool isLargeDesktop(BuildContext context, double width) {
  final platform = Theme.of(context).platform;
  return (platform == TargetPlatform.linux ||
          platform == TargetPlatform.macOS ||
          platform == TargetPlatform.windows) &&
      width >= 1100;
}
