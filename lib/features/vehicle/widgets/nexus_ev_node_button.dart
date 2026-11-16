import 'dart:math';
import 'package:flutter/material.dart';

class NexusEVNodeButton extends StatefulWidget {
  final IconData? icon;          // Icon OR image
  final String? imageAsset;      // NEW: image support
  final Color ringColor;
  final bool active;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NexusEVNodeButton({
    super.key,
    this.icon,
    this.imageAsset,
    required this.ringColor,
    required this.active,
    required this.onTap,
    this.onLongPress,
    this.size = 70,
  }) : assert(icon != null || imageAsset != null,
        "Either icon or imageAsset must be provided");

  @override
  State<NexusEVNodeButton> createState() => _NexusEVNodeButtonState();
}

class _NexusEVNodeButtonState extends State<NexusEVNodeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size / 2;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final pulse = 1 + sin(controller.value * 2 * pi) * 0.06;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: (radius + 26) * 2 * pulse,
                  height: (radius + 26) * 2 * pulse,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.ringColor.withOpacity(0.22),
                    boxShadow: [
                      BoxShadow(
                        color: widget.ringColor.withOpacity(0.22),
                        blurRadius: 45,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // Inner glow
                Container(
                  width: (radius + 10) * 2 * pulse,
                  height: (radius + 10) * 2 * pulse,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.ringColor.withOpacity(0.45),
                    boxShadow: [
                      BoxShadow(
                        color: widget.ringColor.withOpacity(0.45),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Black fill
                Container(
                  width: (radius - 2.4) * 2,
                  height: (radius - 2.4) * 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),

                // Ring
                Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.ringColor,
                      width: 2.4,
                    ),
                  ),
                ),

                // Icon OR Image
                if (widget.imageAsset != null)
                  Image.asset(
                    widget.imageAsset!,
                    width: widget.size * 0.55,
                    height: widget.size * 0.55,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.9),
                  )
                else if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: widget.size * 0.45,
                    color: Colors.white.withOpacity(0.85),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
