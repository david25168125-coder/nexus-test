import 'package:flutter/material.dart';

class NexusHeader extends StatelessWidget {
  final bool isMainPage;
  final VoidCallback? onBack;
  final bool showSettings;
  final String? title;

  const NexusHeader({
    super.key,
    this.isMainPage = false,
    this.onBack,
    this.showSettings = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF242C36))),
      ),
      child: Row(
        children: [
          if (!isMainPage)
            IconButton(
              tooltip: 'Home systems',
              onPressed: onBack,
              icon: const Icon(Icons.grid_view_rounded, size: 22),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title ?? 'NEXUS',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),
          ),
          if (showSettings)
            IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.settings_outlined, size: 22),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    ),
  );
}
