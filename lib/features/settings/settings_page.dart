import 'package:flutter/material.dart';
import 'package:nexus_app/shared/overview_widgets.dart';
import 'alarm_settings_page.dart';

class SettingEntry {
  final String section;
  final String title;
  final IconData icon;
  final String description;
  const SettingEntry(this.section, this.title, this.icon, this.description);
}

const settingsEntries = [
  SettingEntry('General', 'Account', Icons.person_outline,
      'Local household profiles and access permissions will be managed here. No account service is connected.'),
  SettingEntry('General', 'Theme & Appearance', Icons.palette_outlined,
      'The dark theme is active. Display brightness and additional appearance preferences will be added here.'),
  SettingEntry('General', 'Units & Region', Icons.language,
      'Regional preferences for temperature, energy, currency and time will be available here. No preferences are changed by this preview.'),
  SettingEntry('Energy', 'Tariff Settings', Icons.bolt_outlined,
      'Import and export rates will be managed here when the tariff configuration API is connected.'),
  SettingEntry('Energy', 'Solar Configuration', Icons.solar_power_outlined,
      'Solar equipment, sensor mapping and generation settings will be managed here.'),
  SettingEntry('Energy', 'Battery Preferences', Icons.battery_full_outlined,
      'Capacity, backup reserve and charging preferences will be managed here. No battery strategy is applied.'),
  SettingEntry('Energy', 'EV Charging Rules', Icons.ev_station_outlined,
      'Charging limits and preferred charging periods will be configured here. Open EV charging for the existing charger controls.'),
  SettingEntry('Security', 'Alarm Settings', Icons.shield_outlined,
      'Name your alarm using the existing local settings.'),
  SettingEntry('Water System', 'Leak Detection', Icons.water_drop_outlined,
      'Leak detection thresholds and response preferences will be managed here.'),
  SettingEntry('Water System', 'Sensor Pairing', Icons.sensors,
      'Device discovery and local sensor pairing will be managed here. Pairing is not active in this preview.'),
  SettingEntry('Water System', 'Valve Control Settings', Icons.plumbing,
      'Valve preferences will be managed here. Existing valve actions remain on the Water page.'),
  SettingEntry('Vehicle', 'Vehicle Overview', Icons.directions_car_outlined,
      'Vehicle and charging overview.'),
  SettingEntry('Vehicle', 'Driving Efficiency', Icons.speed,
      'Trip energy use and efficiency trends will appear when a vehicle data source is connected.'),
  SettingEntry('Vehicle', 'Location Services', Icons.map_outlined,
      'Vehicle location preferences will be managed here. No location is collected in this preview.'),
  SettingEntry('Notifications', 'Energy Alerts', Icons.notifications_outlined,
      'Energy usage and cost notification preferences will be managed here.'),
  SettingEntry('Notifications', 'Water Leak Alerts', Icons.warning_amber,
      'Leak alert preferences will be managed here. Alert delivery is not configured.'),
  SettingEntry(
      'Notifications',
      'EV Charging Alerts',
      Icons.charging_station_outlined,
      'Charging completion and interruption notifications will be configured here.'),
  SettingEntry('System', 'System Health', Icons.monitor_heart_outlined,
      'Local service availability and device health will appear when monitoring is connected.'),
  SettingEntry('System', 'Local Storage', Icons.storage_outlined,
      'Database usage, retention and backup settings will be managed here.'),
  SettingEntry('System', 'Developer Options', Icons.developer_mode,
      'Diagnostic tools and integration configuration will be available here.'),
  SettingEntry('System', 'About Nexus', Icons.info_outline,
      'Nexus is a local-first intelligent building platform. This experimental interface is under development; some integrations remain unconnected.'),
];

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => OverviewPage(
        title: 'Settings',
        subtitle: 'Make your home work for you.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final section
              in settingsEntries.map((entry) => entry.section).toSet()) ...[
            Text(section, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...settingsEntries
                .where((entry) => entry.section == section)
                .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      tileColor: const Color(0xFF121820),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      leading: Icon(entry.icon),
                      title: Text(entry.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (entry.title == 'Vehicle Overview') {
                          Navigator.pushNamed(context, '/ev');
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      entry.title == 'Alarm Settings'
                                          ? const AlarmSettingsPage()
                                          : SettingDetailPage(entry: entry)));
                        }
                      },
                    ))),
            const SizedBox(height: 24),
          ],
        ]),
      );
}

class SettingDetailPage extends StatelessWidget {
  final SettingEntry entry;
  const SettingDetailPage({super.key, required this.entry});
  @override
  Widget build(BuildContext context) => OverviewPage(
        title: entry.title,
        subtitle: entry.section,
        child: OverviewPanel(
            title: entry.title,
            icon: entry.icon,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  entry.title == 'About Nexus'
                      ? 'Experimental development platform'
                      : 'Preview · configuration not connected',
                  style: const TextStyle(color: Color(0xFF88ACDC))),
              const SizedBox(height: 16),
              Text(entry.description),
            ])),
      );
}
