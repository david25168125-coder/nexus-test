import 'package:flutter/material.dart';

class EVHeader extends StatelessWidget {
  final VoidCallback onClose;

  const EVHeader({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // MG Logo
            Image.asset(
              'assets/ev_ui/MG_logo.png',
              height: 34,
            ),

            const SizedBox(width: 12),

            // Digitize‑Nexus text
            const Text(
              "Digitize‑Nexus",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            // Close button
            GestureDetector(
              onTap: onClose,
              child: const Icon(
                Icons.close,
                size: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
