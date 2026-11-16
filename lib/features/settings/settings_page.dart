import 'package:flutter/material.dart';
import 'alarm_settings_page.dart';   // <-- UPDATED IMPORT

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),

      body: SafeArea(
        child: Column(
          children: [

            // TOP BAR — LOGO + X BUTTON
            Container(
              height: 70,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // CENTER LOGO WITH HALO
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.45),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/digitize_nexus_logo.png',
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Digitize Nexus",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),

                  // X BUTTON (TOP RIGHT)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // BODY CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [

                  // GENERAL
                  _sectionTitle("General"),
                  _settingsTile(icon: Icons.person, title: "Account"),
                  _settingsTile(icon: Icons.palette, title: "Theme & Appearance"),
                  _settingsTile(icon: Icons.language, title: "Units & Region"),

                  const SizedBox(height: 25),

                  // ENERGY
                  _sectionTitle("Energy"),
                  _settingsTile(icon: Icons.bolt, title: "Tariff Settings"),
                  _settingsTile(icon: Icons.solar_power, title: "Solar Configuration"),
                  _settingsTile(icon: Icons.battery_full, title: "Battery Preferences"),
                  _settingsTile(icon: Icons.ev_station, title: "EV Charging Rules"),

                  // 🔥 NEW — ALARM SETTINGS UNDER ENERGY
                  _settingsTile(
                    icon: Icons.shield,
                    title: "Alarm Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlarmSettingsPage(),   // <-- UPDATED
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // WATER SYSTEM
                  _sectionTitle("Water System"),
                  _settingsTile(icon: Icons.water_drop, title: "Leak Detection"),
                  _settingsTile(icon: Icons.sensors, title: "Sensor Pairing"),
                  _settingsTile(icon: Icons.plumbing, title: "Valve Control Settings"),

                  const SizedBox(height: 25),

                  // VEHICLE
                  _sectionTitle("Vehicle"),
                  _settingsTile(icon: Icons.directions_car, title: "Vehicle Overview"),
                  _settingsTile(icon: Icons.speed, title: "Driving Efficiency"),
                  _settingsTile(icon: Icons.map, title: "Location Services"),

                  const SizedBox(height: 25),

                  // NOTIFICATIONS
                  _sectionTitle("Notifications"),
                  _settingsTile(icon: Icons.notifications, title: "Energy Alerts"),
                  _settingsTile(icon: Icons.warning, title: "Water Leak Alerts"),
                  _settingsTile(icon: Icons.charging_station, title: "EV Charging Alerts"),

                  const SizedBox(height: 25),

                  // SYSTEM / ADVANCED
                  _sectionTitle("System"),
                  _settingsTile(icon: Icons.settings_applications, title: "System Health"),
                  _settingsTile(icon: Icons.storage, title: "Local Storage"),
                  _settingsTile(icon: Icons.developer_mode, title: "Developer Options"),
                  _settingsTile(icon: Icons.info_outline, title: "About Nexus"),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  // SETTINGS TILE
  Widget _settingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        onTap: onTap,
      ),
    );
  }
}
