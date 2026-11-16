import 'package:flutter/material.dart';

class OutputsPage extends StatelessWidget {
  const OutputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Outputs",
          style: TextStyle(color: Colors.blue, fontSize: 28),
        ),
      ),
    );
  }
}
