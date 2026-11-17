import 'package:flutter/material.dart';
import 'package:nexus_app/features/home/widgets/nexus_scaffold.dart';

class OverviewPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const OverviewPage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child});
  @override
  Widget build(BuildContext context) => NexusScaffold(
        title: title,
        useBackNavigation: true,
        showSettings: title != 'Settings',
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1680),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 10),
                        Text(subtitle),
                        const SizedBox(height: 28),
                        child,
                        const SizedBox(height: 24),
                      ])),
            )),
      );
}

class OverviewPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  const OverviewPanel(
      {super.key, required this.title, required this.child, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFF121820),
            border: Border.all(color: const Color(0xFF242C36)),
            borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF81CBBE)),
              const SizedBox(width: 12)
            ],
            Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleLarge))
          ]),
          const SizedBox(height: 20),
          child,
        ]),
      );
}

class Reading extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;
  const Reading(this.label, this.value, {super.key, this.detail});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 210,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        if (detail != null) ...[
          const SizedBox(height: 6),
          Text(detail!,
              style: const TextStyle(fontSize: 12, color: Colors.white38))
        ],
      ]));
}

class FutureFeature extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  const FutureFeature(
      {super.key,
      required this.title,
      required this.description,
      this.icon = Icons.auto_awesome_outlined});
  @override
  Widget build(BuildContext context) => OverviewPanel(
      title: title,
      icon: icon,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Not connected yet',
            style: TextStyle(color: Color(0xFF88ACDC))),
        const SizedBox(height: 8),
        Text(description),
      ]));
}
