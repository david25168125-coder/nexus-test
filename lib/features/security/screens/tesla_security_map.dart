import 'package:flutter/material.dart';
import 'dart:math';

class TeslaNode extends StatefulWidget {
  final double radius;
  final Color color;
  final bool active;
  final bool alert;
  final bool badge;
  final IconData? icon;
  final String? label;
  final VoidCallback onTap;

  const TeslaNode({
    super.key,
    required this.radius,
    required this.color,
    required this.active,
    required this.alert,
    required this.badge,
    this.icon,
    this.label,
    required this.onTap,
  });

  @override
  State<TeslaNode> createState() => _TeslaNodeState();
}

class _TeslaNodeState extends State<TeslaNode>
    with TickerProviderStateMixin {
  late AnimationController pulse;
  late AnimationController ripple;

  @override
  void initState() {
    super.initState();

    pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    pulse.dispose();
    ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double glowIntensity = widget.active ? 1.0 : 0.4;
    final double pulseValue = (pulse.value * 6);

    return GestureDetector(
      onTap: () {
        ripple.forward(from: 0);
        widget.onTap();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (_, __) {
              return Container(
                width: widget.radius * 2 + pulseValue,
                height: widget.radius * 2 + pulseValue,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(glowIntensity),
                      blurRadius: widget.active ? 35 : 15,
                      spreadRadius: widget.active ? 6 : 2,
                    ),
                  ],
                ),
              );
            },
          ),

          // Ripple effect
          AnimatedBuilder(
            animation: ripple,
            builder: (_, __) {
              final double r = ripple.value * widget.radius * 2;
              return Container(
                width: r,
                height: r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(1 - ripple.value),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Main node
          Container(
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.15),
              border: Border.all(
                color: widget.color.withOpacity(glowIntensity),
                width: 2,
              ),
            ),
            child: widget.icon != null
                ? Icon(widget.icon, color: widget.color, size: widget.radius * 0.9)
                : null,
          ),

          // Badge dot
          if (widget.badge)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Label
          if (widget.label != null)
            Positioned(
              bottom: -28,
              child: Text(
                widget.label!,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
