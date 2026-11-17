import 'package:flutter/material.dart';
import 'package:nexus_app/features/home/widgets/tesla_energy_map.dart';
import 'package:nexus_app/core/models/nexus_energy_state.dart';

class NexusEnergyMap extends StatelessWidget {
  final NexusEnergyState data;

  const NexusEnergyMap({super.key, required this.data});

  void _showReading(BuildContext context, String title, double kw, double kwh) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Text('Power now: ${kw.toStringAsFixed(2)} kW'),
              const SizedBox(height: 12),
              Text('Today: ${kwh.toStringAsFixed(1)} kWh'),
              const SizedBox(height: 16),
              const Text('Readings supplied by Nexus Core.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Same positions as your painter
        final centerX = w / 2;
        final centerY = h / 2;

        final landscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;
        final verticalOffset = h * (landscape ? 0.22 : 0.28);
        final horizontalOffset = w * (landscape ? 0.32 : 0.28);

        final solarPos = Offset(centerX, centerY - verticalOffset);
        final batteryPos = Offset(centerX, centerY + verticalOffset);
        final gridPos = Offset(centerX - horizontalOffset, centerY);
        final evPos = Offset(centerX + horizontalOffset, centerY);
        final homePos = Offset(centerX, centerY);

        return Stack(
          children: [
            ClipRect(
              child: TeslaEnergyMap(
                solarKw: data.solarKw,
                batteryKw: data.batteryKw,
                liveGridKw: data.gridKw,
                liveHomeKw: data.homeKw,
                liveEvKw: -data.evKw,
                solarDayKwh: data.solarDayKwh,
                batteryDayKwh: data.batteryDayKwh,
                evDayKwh: data.evDayKwh,
                gridDayKwh: data.gridDayKwh,
                homeDayKwh: data.homeDayKwh,
                importTariffP: data.importTariffP,
                exportTariffP: data.exportTariffP,
                solarComms: data.solarComms,
                batteryComms: data.batteryComms,
                evComms: data.evComms,
                gridComms: data.gridComms,
                solarFault: data.solarFault,
                batteryFault: data.batteryFault,
                evFault: data.evFault,
                gridFault: data.gridFault,
                homeCostBand: data.homeCostBand,
              ),
            ),

            // -----------------------------
            // TAP ZONES
            // -----------------------------

            // Solar
            Positioned(
              left: solarPos.dx - 40,
              top: solarPos.dy - 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showReading(
                  context,
                  'Solar',
                  data.solarKw,
                  data.solarDayKwh,
                ),
                child: const SizedBox(width: 80, height: 80),
              ),
            ),

            // Grid
            Positioned(
              left: gridPos.dx - 40,
              top: gridPos.dy - 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    _showReading(context, 'Grid', data.gridKw, data.gridDayKwh),
                child: const SizedBox(width: 80, height: 80),
              ),
            ),

            // EV
            Positioned(
              left: evPos.dx - 40,
              top: evPos.dy - 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showReading(
                  context,
                  'EV charging',
                  data.evKw,
                  data.evDayKwh,
                ),
                child: const SizedBox(width: 80, height: 80),
              ),
            ),

            // Battery
            Positioned(
              left: batteryPos.dx - 40,
              top: batteryPos.dy - 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showReading(
                  context,
                  'Battery',
                  data.batteryKw,
                  data.batteryDayKwh,
                ),
                child: const SizedBox(width: 80, height: 80),
              ),
            ),

            // Home (larger)
            Positioned(
              left: homePos.dx - 60,
              top: homePos.dy - 60,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    _showReading(context, 'Home', data.homeKw, data.homeDayKwh),
                child: const SizedBox(width: 120, height: 120),
              ),
            ),
          ],
        );
      },
    );
  }
}
