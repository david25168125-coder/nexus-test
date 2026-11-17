import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/features/home/widgets/nexus_header.dart';
import 'package:nexus_app/theme/nexus_theme.dart';

void main() {
  for (final setup in [
    (
      name: 'desktop',
      size: const Size(1440, 1000),
      platform: TargetPlatform.linux,
      centered: true,
    ),
    (
      name: 'landscape tablet',
      size: const Size(1280, 800),
      platform: TargetPlatform.android,
      centered: false,
    ),
    (
      name: 'large tablet',
      size: const Size(1366, 1024),
      platform: TargetPlatform.iOS,
      centered: false,
    ),
    (
      name: 'NSPanel-sized screen',
      size: const Size(480, 480),
      platform: TargetPlatform.android,
      centered: false,
    ),
  ]) {
    testWidgets(
      '${setup.name} places one logo outside the camera area when needed',
      (tester) async {
        tester.view.physicalSize = setup.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var systemsOpened = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: nexusTheme.copyWith(platform: setup.platform),
            routes: {
              '/settings': (_) => const Scaffold(body: Text('Settings page')),
            },
            home: Scaffold(
              body: Column(
                children: [NexusHeader(onBack: () => systemsOpened = true)],
              ),
            ),
          ),
        );
        final logo = find.byType(Image);
        expect(logo, findsOneWidget);
        expect(
          (tester.widget<Image>(logo).image as AssetImage).assetName,
          'assets/digitize_nexus_logo.png',
        );
        expect(find.text('NEXUS'), findsNothing);
        final position = tester.getCenter(logo);
        if (setup.centered) {
          expect(position.dx, closeTo(setup.size.width / 2, 1));
        } else {
          expect(
            tester.getRect(logo).right,
            lessThan(setup.size.width / 2 - 24),
          );
        }
        await tester.tap(find.byTooltip('Home systems'));
        expect(systemsOpened, isTrue);
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Settings page'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'desktop kiosk override keeps branding left and preserves page title',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: nexusTheme.copyWith(platform: TargetPlatform.linux),
          home: const Scaffold(
            body: Column(
              children: [
                NexusHeader(centerBrand: false, title: 'Security Overview'),
              ],
            ),
          ),
        ),
      );
      expect(tester.getRect(find.byType(Image)).right, lessThan(200));
      expect(find.text('Security Overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
