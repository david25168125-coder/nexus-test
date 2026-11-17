import 'package:flutter/material.dart';
import 'package:nexus_app/shared/nexus_brand.dart';

class NexusHeader extends StatelessWidget {
  final bool isMainPage;
  final VoidCallback? onBack;
  final bool showSettings;
  final String? title;
  final bool showBrand;
  final bool backNavigation;
  final VoidCallback? onDashboard;

  /// Kiosk installations can force left alignment even on a desktop host.
  /// Otherwise only spacious desktop layouts centre the brand.
  final bool? centerBrand;

  const NexusHeader({
    super.key,
    this.isMainPage = false,
    this.onBack,
    this.showSettings = true,
    this.title,
    this.showBrand = true,
    this.backNavigation = false,
    this.onDashboard,
    this.centerBrand,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final desktop = platform == TargetPlatform.linux ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows;

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centered = centerBrand ??
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
                    tooltip: backNavigation ? 'Back' : 'Home systems',
                    onPressed: onBack,
                    icon: Icon(
                        backNavigation
                            ? Icons.arrow_back_rounded
                            : Icons.grid_view_rounded,
                        size: 22),
                  )
                else if (centered)
                  const SizedBox(width: 48),
                Expanded(
                  child: Align(
                    alignment:
                        centered ? Alignment.center : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showBrand)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: NexusBrand(),
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
                if (onDashboard != null)
                  IconButton(
                    tooltip: 'Dashboard',
                    onPressed: onDashboard,
                    icon: const Icon(Icons.home_outlined, size: 22),
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
