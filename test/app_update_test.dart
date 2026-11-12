import 'package:admineventpro/data_layer/services/app_update_service.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/update_available_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The decisions the update gate makes, and what the update screen offers.
///
/// The fetch itself needs a Firebase app, so it is not exercised here. What
/// is covered is everything the fetch feeds: which build numbers mean which
/// kind of update, which store URL each platform is sent to, and whether the
/// screen leaves a way out. Those are the parts that can strand a user.
void main() {
  const String packageName = 'apps.admin.admineventpro';

  group('which update the build numbers call for', () {
    test('installed build equals latest — nothing to prompt', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 7, latestBuild: 7, minimumBuild: 5),
        AppUpdateRequirement.none,
      );
    });

    test('installed build ahead of latest — nothing to prompt', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 9, latestBuild: 7, minimumBuild: 5),
        AppUpdateRequirement.none,
      );
    });

    test('below latest but at or above the minimum — optional', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 5, latestBuild: 7, minimumBuild: 5),
        AppUpdateRequirement.optional,
      );
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 6, latestBuild: 7, minimumBuild: 5),
        AppUpdateRequirement.optional,
      );
    });

    test('below the minimum — mandatory, even when also below latest', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 4, latestBuild: 7, minimumBuild: 5),
        AppUpdateRequirement.mandatory,
      );
    });

    test('the minimum outranks the latest when both would fire', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 1, latestBuild: 2, minimumBuild: 2),
        AppUpdateRequirement.mandatory,
      );
    });

    test(
        'an unfetched config — every parameter at its zero default — never '
        'prompts, so an offline first launch behaves as before', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 7, latestBuild: 0, minimumBuild: 0),
        AppUpdateRequirement.none,
      );
    });

    test('a build number the platform did not report is not "ancient"', () {
      expect(
        AppUpdateService.requirementFor(
            currentBuild: 0, latestBuild: 999, minimumBuild: 999),
        AppUpdateRequirement.none,
      );
      expect(
        AppUpdateService.requirementFor(
            currentBuild: -1, latestBuild: 999, minimumBuild: 999),
        AppUpdateRequirement.none,
      );
    });

    test('the zero defaults are the ones the service registers', () {
      expect(AppUpdateService.defaults[AppUpdateService.keyLatestBuild], 0);
      expect(AppUpdateService.defaults[AppUpdateService.keyMinimumBuild], 0);
    });
  });

  group('where each platform is sent', () {
    test('Android uses the configured Play listing when there is one', () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.android,
          configuredPlayUrl: 'https://play.google.com/store/apps/details?id=x',
          configuredAppStoreUrl: '',
          packageName: packageName,
        ),
        'https://play.google.com/store/apps/details?id=x',
      );
    });

    test('Android with no configured URL derives one from the app id', () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.android,
          configuredPlayUrl: '   ',
          configuredAppStoreUrl: '',
          packageName: packageName,
        ),
        'https://play.google.com/store/apps/details?id=$packageName',
      );
    });

    test('iOS is never sent to Google Play, even when Play is configured', () {
      final url = AppUpdateService.storeUrlFor(
        platform: TargetPlatform.iOS,
        configuredPlayUrl: 'https://play.google.com/store/apps/details?id=x',
        configuredAppStoreUrl: '',
        packageName: packageName,
      );
      expect(url, isEmpty, reason: 'an empty URL suppresses the prompt');
      expect(url, isNot(contains('play.google.com')));
    });

    test('iOS uses app_store_url when the console provides one', () {
      expect(
        AppUpdateService.storeUrlFor(
          platform: TargetPlatform.iOS,
          configuredPlayUrl: '',
          configuredAppStoreUrl: 'https://apps.apple.com/app/id123456789',
          packageName: packageName,
        ),
        'https://apps.apple.com/app/id123456789',
      );
    });

    test('a platform with no store gets nothing, which suppresses the gate',
        () {
      for (final platform in <TargetPlatform>[
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(
          AppUpdateService.storeUrlFor(
            platform: platform,
            configuredPlayUrl: 'https://play.google.com/x',
            configuredAppStoreUrl: 'https://apps.apple.com/x',
            packageName: packageName,
          ),
          isEmpty,
        );
      }
    });

    test('the native scheme opens the store app on each platform', () {
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.android,
          storeUrl: 'https://play.google.com/store/apps/details?id=x',
          packageName: packageName,
        ),
        'market://details?id=$packageName',
      );
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.iOS,
          storeUrl: 'https://apps.apple.com/app/id123456789',
          packageName: packageName,
        ),
        'itms-apps://apps.apple.com/app/id123456789',
      );
      expect(
        AppUpdateService.nativeStoreUrlFor(
          platform: TargetPlatform.iOS,
          storeUrl: '',
          packageName: packageName,
        ),
        isNull,
      );
    });
  });

  group('the update screen', () {
    const optional = AppUpdateInfo(
      requirement: AppUpdateRequirement.optional,
      currentVersion: '2.0.7',
      currentBuild: 7,
      latestVersion: '2.1.0',
      latestBuild: 9,
      message: 'Faster vendor uploads and a new budget tracker.',
      storeUrl: 'https://play.google.com/store/apps/details?id=$packageName',
      nativeStoreUrl: 'market://details?id=$packageName',
    );

    const mandatory = AppUpdateInfo(
      requirement: AppUpdateRequirement.mandatory,
      currentVersion: '1.9.0',
      currentBuild: 3,
      latestVersion: '2.1.0',
      latestBuild: 9,
      message: 'This version is no longer supported.',
      storeUrl: 'https://play.google.com/store/apps/details?id=$packageName',
      nativeStoreUrl: 'market://details?id=$packageName',
    );

    Future<void> pumpScreen(
      WidgetTester tester,
      AppUpdateInfo info, {
      VoidCallback? onLater,
    }) async {
      await tester.pumpWidget(MaterialApp(
        home: UpdateAvailableScreen(info: info, onLater: onLater),
      ));
      await tester.pump();
    }

    testWidgets('shows the heading, the message and both versions',
        (tester) async {
      await pumpScreen(tester, optional, onLater: () {});

      expect(find.text('A New Version Is Here!'), findsOneWidget);
      expect(find.text(optional.message), findsOneWidget);
      expect(find.text('2.0.7 (7)'), findsOneWidget);
      expect(find.text('2.1.0 (9)'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);
    });

    testWidgets('an optional update offers Maybe Later and it continues',
        (tester) async {
      var continued = 0;
      await pumpScreen(tester, optional, onLater: () => continued++);

      expect(find.text('Maybe Later'), findsOneWidget);
      expect(find.text('Required update'), findsNothing);

      await tester.tap(find.text('Maybe Later'));
      await tester.pump();
      expect(continued, 1);
    });

    testWidgets('a mandatory update has no way past it', (tester) async {
      await pumpScreen(tester, mandatory);

      expect(find.text('Maybe Later'), findsNothing);
      expect(find.text('Required update'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse,
          reason: 'the system back gesture must not dismiss it');
    });

    testWidgets('falls back to the build number when no version is published',
        (tester) async {
      await pumpScreen(
        tester,
        const AppUpdateInfo(
          requirement: AppUpdateRequirement.optional,
          currentVersion: '2.0.7',
          currentBuild: 7,
          latestVersion: '',
          latestBuild: 9,
          message: 'Update available.',
          storeUrl: 'https://play.google.com/store/apps/details?id=x',
        ),
        onLater: () {},
      );

      expect(find.text('Build 9'), findsOneWidget);
    });

    testWidgets('renders within a short screen without overflowing',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1680);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pumpScreen(tester, optional, onLater: () {});
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
