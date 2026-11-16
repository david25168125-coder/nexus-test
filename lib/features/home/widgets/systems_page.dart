import 'package:flutter/material.dart';

class SystemsPage extends StatelessWidget {
  final VoidCallback onClose;

  const SystemsPage({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            // ---------------------------------------------------------
            // TOP BAR WITH CLOSE BUTTON
            // ---------------------------------------------------------
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------
            // SCROLLABLE SYSTEMS LIST (NEW ORDER)
            // ---------------------------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 1. SECURITY
                  _systemTile(
                    context,
                    image: 'assets/systems/security.jpg',
                    title: 'Security',
                    subtitle: 'Cameras & sensors',
                    route: '/security',
                  ),

                  // 2. EV
                  _systemTile(
                    context,
                    image: 'assets/systems/EV.jpg',
                    title: 'EV',
                    subtitle: 'Charging status',
                    route: '/ev',
                  ),

                  // 3. SOLAR
                  _systemTile(
                    context,
                    image: 'assets/systems/solar.jpg',
                    title: 'Solar',
                    subtitle: 'Live generation',
                    route: '/solar',
                  ),

                  // 4. HEATING
                  _systemTile(
                    context,
                    image: 'assets/systems/heating.jpg',
                    title: 'Heating',
                    subtitle: 'Temperature & boiler',
                    route: '/heating',
                  ),

                  // 5. BATTERY
                  _systemTile(
                    context,
                    image: 'assets/systems/battery.jpg',
                    title: 'Battery',
                    subtitle: 'Storage & backup',
                    route: '/battery',
                  ),

                  // 6. WATER
                  _systemTile(
                    context,
                    image: 'assets/systems/water.jpg',
                    title: 'Water',
                    subtitle: 'Flow & valve control',
                    route: '/water',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SYSTEM TILE WIDGET
  // ---------------------------------------------------------
  Widget _systemTile(
    BuildContext context, {
    required String image,
    required String title,
    required String subtitle,
    required String route,
  }) {
    final available = const {'/security', '/ev', '/water'}.contains(route);
    return GestureDetector(
      onTap: available
          ? () {
              onClose();
              Navigator.pushNamed(context, route);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 160,
        child: Row(
          children: [
            // LEFT — TEXT (40%)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    available ? subtitle : 'Not configured',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // RIGHT — IMAGE (60%)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
