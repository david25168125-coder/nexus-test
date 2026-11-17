import 'package:flutter/material.dart';

class NexusHeader extends StatelessWidget {
  final bool isMainPage;
  final VoidCallback? onBack;
  final bool showSettings;
  final String? title;

  /// Kiosk installations can force left alignment even on a desktop host.
  /// Otherwise only spacious desktop layouts centre the brand.
  final bool? centerBrand;

  const NexusHeader({
    super.key,
    this.isMainPage = false,
    this.onBack,
    this.showSettings = true,
    this.title,
    this.centerBrand,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final desktop =
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows;

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centered =
              centerBrand ??
              (desktop &&
                  constraints.maxWidth >= 1100 &&
                  MediaQuery.sizeOf(context).shortestSide >= 900);
          return Container(
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
                else if (centered)
                  const SizedBox(width: 48),
                Expanded(
                  child: Align(
                    alignment: centered
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Image.asset(
                            'assets/digitize_nexus_logo.png',
                            width: 36,
                            height: 36,
                            semanticLabel: 'Nexus',
                          ),
                        ),
                        if (title != null)
                          Flexible(
                            child: Text(
                              title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (showSettings)
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings_outlined, size: 22),
                  )
                else if (centered)
                  const SizedBox(width: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
