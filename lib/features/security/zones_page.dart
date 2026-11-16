import 'package:flutter/material.dart';

class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Zones",
          style: TextStyle(color: Colors.red, fontSize: 28),
        ),
      ),
    );
  }
}
