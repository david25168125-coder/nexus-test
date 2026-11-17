import 'package:flutter/material.dart';
import 'package:nexus_app/shared/nexus_brand.dart';
import 'nexus_header.dart';
import 'systems_page.dart';

class NexusScaffold extends StatefulWidget {
  final Widget child;
  final bool isMainPage;
  final bool showSettings;
  final String? title;
  final bool useBackNavigation;
  const NexusScaffold(
      {super.key,
      required this.child,
      this.isMainPage = false,
      this.showSettings = false,
      this.title,
      this.useBackNavigation = false});
  @override
  State<NexusScaffold> createState() => _NexusScaffoldState();
}

class _NexusScaffoldState extends State<NexusScaffold> {
  bool systemsOpen = false;
  void dashboard() =>
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  void back() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      dashboard();
    }
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final desktop = isLargeDesktop(context, constraints.maxWidth) &&
            constraints.maxHeight >= 650;
        return Scaffold(
          backgroundColor: const Color(0xFF090C11),
          body: Row(children: [
            if (desktop)
              const SizedBox(
                  width: 220,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Color(0xFF242C36)))),
                      child: Material(
                          color: Color(0xFF0D1117),
                          child: SystemsNavigation()))),
            Expanded(
                child: Stack(children: [
              Column(children: [
                NexusHeader(
                  isMainPage: desktop && !widget.useBackNavigation,
                  title: widget.title,
                  showBrand: !desktop,
                  backNavigation: widget.useBackNavigation,
                  onDashboard: widget.useBackNavigation ? dashboard : null,
                  onBack: widget.useBackNavigation
                      ? back
                      : () => setState(() => systemsOpen = true),
                  showSettings: widget.showSettings,
                ),
                Expanded(child: widget.child),
              ]),
              if (!desktop && systemsOpen)
                SystemsPage(onClose: () => setState(() => systemsOpen = false)),
            ])),
          ]),
        );
      });
}
