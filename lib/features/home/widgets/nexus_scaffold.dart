import 'package:flutter/material.dart';
import 'package:nexus_app/features/home/widgets/nexus_header.dart';
import 'package:nexus_app/features/home/widgets/systems_page.dart';

class NexusScaffold extends StatefulWidget {
  final Widget child;

  // This now ONLY controls the left arrow
  final bool isMainPage;

  // NEW: controls the right settings icon
  final bool showSettings;

  const NexusScaffold({
    super.key,
    required this.child,
    this.isMainPage = false,
    this.showSettings = false,
  });

  @override
  State<NexusScaffold> createState() => _NexusScaffoldState();
}

class _NexusScaffoldState extends State<NexusScaffold> {
  bool systemsOpen = false;

  void _openSystems() {
    setState(() => systemsOpen = true);
  }

  void _closeSystems() {
    setState(() => systemsOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: Stack(
        children: [
          Column(
            children: [
              NexusHeader(
                isMainPage: widget.isMainPage,
                onBack: widget.isMainPage ? null : _openSystems,
                showSettings: widget.showSettings,
              ),
              Expanded(child: widget.child),
            ],
          ),

          if (systemsOpen)
            SystemsPage(onClose: _closeSystems),
        ],
      ),
    );
  }
}
