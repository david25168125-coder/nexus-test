import 'package:flutter/material.dart';

class VehicleOverviewPage extends StatelessWidget {
  const VehicleOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Vehicle Overview',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'EV Overview Coming Soon',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
