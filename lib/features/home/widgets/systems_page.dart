import 'package:flutter/material.dart';
import 'package:nexus_app/shared/nexus_brand.dart';

const systemDestinations = [
  (title: 'Your Home', icon: Icons.home_outlined, route: '/'),
  (title: 'Security', icon: Icons.shield_outlined, route: '/security'),
  (title: 'EV charging', icon: Icons.ev_station_outlined, route: '/ev'),
  (title: 'Solar', icon: Icons.solar_power_outlined, route: '/solar'),
  (title: 'Battery', icon: Icons.battery_charging_full, route: '/battery'),
  (title: 'Heating', icon: Icons.thermostat_outlined, route: '/heating'),
  (title: 'Water', icon: Icons.water_drop_outlined, route: '/water'),
  (title: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
];

class SystemsNavigation extends StatelessWidget {
  final VoidCallback? onClose;
  const SystemsNavigation({super.key, this.onClose});
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 24),
            child: Row(children: [
              const NexusBrand(size: 40),
              const Spacer(),
              if (onClose != null)
                IconButton(
                    tooltip: 'Close systems',
                    onPressed: onClose,
                    icon: const Icon(Icons.close)),
            ]),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('CONNECTED',
                  style: Theme.of(context).textTheme.labelSmall)),
          const SizedBox(height: 16),
          Expanded(
              child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: systemDestinations.map((item) {
              final selected =
                  ModalRoute.of(context)?.settings.name == item.route;
              return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    selected: selected,
                    selectedTileColor: const Color(0xFF19252A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    leading: Icon(item.icon, size: 21),
                    title: Text(item.title),
                    onTap: () {
                      onClose?.call();
                      if (selected) return;
                      if (item.route == '/') {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        Navigator.pushNamed(context, item.route);
                      }
                    },
                  ));
            }).toList(),
          )),
          const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Local building control',
                  style: TextStyle(fontSize: 12, color: Colors.white38))),
        ]),
      );
}

class SystemsPage extends StatelessWidget {
  final VoidCallback onClose;
  const SystemsPage({super.key, required this.onClose});
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Material(
            color: const Color(0xFF090C11),
            child: SystemsNavigation(onClose: onClose)),
      );
}
