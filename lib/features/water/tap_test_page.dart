import 'package:flutter/material.dart';
import 'tap_animation.dart';

class TapTestPage extends StatelessWidget {
  const TapTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TapAnimation(), // <-- no params, no rebuilds
      ),
    );
  }
}
