import 'package:flutter/material.dart';
import 'package:nexus_app/features/home/widgets/nexus_header.dart';
import 'package:nexus_app/features/home/widgets/nexus_footer.dart';
import '../widgets/soc_ring.dart';

class EVOverview extends StatelessWidget {
  const EVOverview({super.key});

  bool _isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  Widget build(BuildContext context) {
    final landscape = _isLandscape(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // PREMIUM HEADER
          NexusHeader(
            isMainPage: false,
            onBack: () => Navigator.pop(context),
            title: "EV Overview",
            showSettings: true,
          ),

          // MAIN CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // HERO SECTION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const Text(
                              "MG IM5",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // CAR IMAGE (same size logic)
                            Image.asset(
                              'assets/systems/EV.jpg',
                              height: landscape ? 150 : 200,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 20),

                            SOCRing(
                              percentage: 72,
                              size: landscape ? 120 : 160,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Estimated Range: 182 miles",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: landscape ? 14 : 16,
                              ),
                            ),
                          ],
                        ),

                        // MG LOGO TOP RIGHT
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // future: open vehicle selector
                            },
                            onLongPress: () {
                              debugPrint("Hold detected: open vehicle selector");
                            },
                            child: Image.asset(
                              'assets/systems/mg_logo.png',
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // STATUS GRID
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: landscape ? 2.2 : 1.4,
                    children: const [
                      _StatusCard(
                        title: "Pre‑Drive",
                        value: "Comfort",
                        icon: Icons.settings_suggest,
                      ),
                      _StatusCard(
                        title: "Doors",
                        value: "Locked",
                        icon: Icons.lock,
                      ),
                      _StatusCard(
                        title: "Status",
                        value: "Normal",
                        icon: Icons.check_circle,
                      ),
                      _StatusCard(
                        title: "Odometer",
                        value: "7,540 km",
                        icon: Icons.speed,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // QUICK ACTION ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _QuickAction(icon: Icons.description, label: "Docs"),
                      _QuickAction(icon: Icons.ac_unit, label: "HVAC"),
                      _QuickAction(icon: Icons.alarm, label: "Alarm"),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // FOOTER
          const NexusFooter(),
        ],
      ),
    );
  }
}

// STATUS CARD
class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// QUICK ACTION BUTTON
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
