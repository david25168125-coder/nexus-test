import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'water_controller.dart';
import 'tap_animation.dart';

class WaterPage extends ConsumerStatefulWidget {
  const WaterPage({super.key});

  @override
  ConsumerState<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends ConsumerState<WaterPage> {
  String usagePeriod = "day"; // day, month, year

  @override
  Widget build(BuildContext context) {
    final water = ref.watch(waterControllerProvider);
    final controller = ref.read(waterControllerProvider.notifier);
    final status = water.status;

    return Scaffold(
      backgroundColor: Colors.black,
      body: water.loading || status == null
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // ---------------------------------------------------------
                // LEFT SIDE — FULL HEIGHT TAP ANIMATION
                // ---------------------------------------------------------
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: TapAnimation(
                      isOpen: status.valveOpen,
                      isLocked: status.valveLocked,
                    ),
                  ),
                ),

                // ---------------------------------------------------------
                // RIGHT SIDE — USAGE + CONTROLS
                // ---------------------------------------------------------
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PERIOD SWITCHER
                        Row(
                          children: [
                            _periodButton("Day", "day"),
                            const SizedBox(width: 10),
                            _periodButton("Month", "month"),
                            const SizedBox(width: 10),
                            _periodButton("Year", "year"),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // USAGE DISPLAY
                        Text(
                          "Water Usage (${usagePeriod.toUpperCase()})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _getUsageText(status),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // VALVE STATE
                        Text(
                          "Valve: ${status.valveOpen ? "OPEN" : "CLOSED"}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // LOCK STATE
                        Text(
                          "Lock: ${status.valveLocked ? "LOCKED" : "UNLOCKED"}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),

                        const Spacer(),

                        // OPEN / CLOSE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: status.valveLocked
                                ? null
                                : status.valveOpen
                                    ? controller.closeValve
                                    : controller.openValve,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  status.valveOpen ? Colors.red : Colors.green,
                            ),
                            child: Text(
                              status.valveOpen ? "Close Valve" : "Open Valve",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // LOCK / UNLOCK BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: status.valveLocked
                                ? controller.unlockValve
                                : controller.lockValve,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              status.valveLocked ? "Unlock" : "Lock",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------
  // PERIOD BUTTON WIDGET
  // ---------------------------------------------------------
  Widget _periodButton(String label, String value) {
    final bool active = usagePeriod == value;

    return GestureDetector(
      onTap: () => setState(() => usagePeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // USAGE TEXT (placeholder until you add real usage data)
  // ---------------------------------------------------------
  String _getUsageText(status) {
    switch (usagePeriod) {
      case "day":
        return "12.4 L today";
      case "month":
        return "310 L this month";
      case "year":
        return "3,820 L this year";
      default:
        return "";
    }
  }
}
