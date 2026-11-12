import 'dart:async';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// How urgently the installed build needs replacing.
enum AppUpdateRequirement {
  /// Nothing to do — the installed build is current, or the check could not
  /// reach a verdict it is safe to act on.
  none,

  /// A newer build exists and the user may postpone it.
  optional,

  /// The installed build is below the minimum the backend still supports, so
  /// it must not be allowed into authenticated screens.
  mandatory,
}

/// The verdict of one version check, plus everything the update screen needs
/// to render itself and reach the right store listing.
@immutable
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.requirement,
    required this.currentVersion,
    required this.currentBuild,
    required this.latestVersion,
    required this.latestBuild,
    required this.message,
    required this.storeUrl,
    this.nativeStoreUrl,
  });

  /// The "carry on as before" verdict, used whenever the check cannot produce
  /// a trustworthy answer. Deliberately the cheapest possible value to build
  /// so that no failure path can itself fail.
  const AppUpdateInfo.none()
      : requirement = AppUpdateRequirement.none,
        currentVersion = '',
        currentBuild = 0,
        latestVersion = '',
        latestBuild = 0,
        message = '',
        storeUrl = '',
        nativeStoreUrl = null;

  final AppUpdateRequirement requirement;

  /// Marketing version of the installed build, e.g. `2.0.7`.
  final String currentVersion;

  /// Build number of the installed build, e.g. `7`.
  final int currentBuild;

  /// Marketing version being offered, straight from Remote Config.
  final String latestVersion;
  final int latestBuild;

  /// Copy shown under the heading, straight from Remote Config.
  final String message;

  /// The https listing. Always safe to open in a browser.
  final String storeUrl;

  /// A scheme that opens the platform's store app directly (`market://` on
  /// Android, `itms-apps://` on iOS). Tried first, with [storeUrl] as the
  /// fallback, because the store app gives a one-tap install.
  final String? nativeStoreUrl;

  /// Whether the user must update before going any further.
  bool get isBlocking => requirement == AppUpdateRequirement.mandatory;

  /// Whether an update screen should be shown at all.
  bool get shouldPrompt => requirement != AppUpdateRequirement.none;
}

/// Compares the installed build against the numbers published in Firebase
/// Remote Config.
///
/// Every failure mode resolves to [AppUpdateInfo.none]: a missing config, an
/// unreachable network, an unparseable build number, a platform with no store
/// URL. Blocking the app is a far worse outcome than missing an update
/// prompt, so the check only ever speaks up when it is certain.
class AppUpdateService {
  AppUpdateService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  // Remote Config parameter names. These must match the keys in the Firebase
  // console for project event-master-2bf93.
  static const String keyLatestBuild = 'latest_build_number';
  static const String keyMinimumBuild = 'minimum_supported_build_number';
  static const String keyLatestVersion = 'latest_version';
  static const String keyUpdateMessage = 'update_message';
  static const String keyPlayStoreUrl = 'play_store_url';

  /// Not in the original parameter list, but iOS users must never be sent to
  /// Google Play. Leaving this unset simply disables the prompt on iOS.
  static const String keyAppStoreUrl = 'app_store_url';

  /// Values used until a fetch succeeds, and whenever one never does.
  ///
  /// Both build numbers default to zero so that an un-fetched config can
  /// never satisfy `installed < latest` — a device that has never reached
  /// Remote Config behaves exactly as it did before this feature existed.
  static final Map<String, dynamic> defaults = <String, dynamic>{
    keyLatestBuild: 0,
    keyMinimumBuild: 0,
    keyLatestVersion: '',
    keyUpdateMessage:
        'A new version of Admin Event Pro is available with the latest '
            'improvements and fixes.',
    keyPlayStoreUrl: '',
    keyAppStoreUrl: '',
  };

  /// Runs the whole check: configure, fetch, read the installed version,
  /// compare.
  ///
  /// [timeout] caps the entire operation, not just the network leg, so a
  /// wedged plugin channel cannot strand the user on the splash screen. It is
  /// meant to be awaited concurrently with the splash dwell, so in practice
  /// it costs nothing on a healthy device.
  Future<AppUpdateInfo> check({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      return await _check().timeout(timeout);
    } on TimeoutException {
      log('App update check timed out after ${timeout.inSeconds}s — '
          'continuing without a prompt');
      return const AppUpdateInfo.none();
    } catch (error) {
      log('App update check failed ($error) — continuing without a prompt');
      return const AppUpdateInfo.none();
    }
  }

  Future<AppUpdateInfo> _check() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(packageInfo.buildNumber.trim()) ?? 0;

    // Nothing sensible to compare against. Happens on platforms that do not
    // report a build number, and must not be read as "older than everything".
    if (currentBuild <= 0) {
      log('Installed build number "${packageInfo.buildNumber}" is not a '
          'positive integer — skipping the update check');
      return const AppUpdateInfo.none();
    }

    await _prepare();

    final latestBuild = _remoteConfig.getInt(keyLatestBuild);
    final minimumBuild = _remoteConfig.getInt(keyMinimumBuild);

    final requirement = requirementFor(
      currentBuild: currentBuild,
      latestBuild: latestBuild,
      minimumBuild: minimumBuild,
    );
    if (requirement == AppUpdateRequirement.none) {
      return const AppUpdateInfo.none();
    }

    final storeUrl = storeUrlFor(
      platform: defaultTargetPlatform,
      configuredPlayUrl: _remoteConfig.getString(keyPlayStoreUrl),
      configuredAppStoreUrl: _remoteConfig.getString(keyAppStoreUrl),
      packageName: packageInfo.packageName,
    );
    if (storeUrl.isEmpty) {
      // Showing an update screen whose only button cannot work would strand
      // the user, and on the mandatory path it would brick the app.
      log('No store URL configured for $defaultTargetPlatform — '
          'suppressing the update prompt');
      return const AppUpdateInfo.none();
    }

    final message = _remoteConfig.getString(keyUpdateMessage).trim();

    return AppUpdateInfo(
      requirement: requirement,
      currentVersion: packageInfo.version,
      currentBuild: currentBuild,
      latestVersion: _remoteConfig.getString(keyLatestVersion).trim(),
      latestBuild: latestBuild,
      message:
          message.isNotEmpty ? message : defaults[keyUpdateMessage]! as String,
      storeUrl: storeUrl,
      nativeStoreUrl: nativeStoreUrlFor(
        platform: defaultTargetPlatform,
        storeUrl: storeUrl,
        packageName: packageInfo.packageName,
      ),
    );
  }

  /// Registers the defaults and refreshes the values.
  ///
  /// A failed fetch is not fatal: Remote Config keeps the last activated
  /// values on disk, so an offline launch still sees whatever the previous
  /// successful fetch produced, and a device that has never fetched sees
  /// [defaults].
  Future<void> _prepare() async {
    await _remoteConfig.setDefaults(defaults);
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        // Release builds respect Firebase's throttling so startup does not
        // make a network round trip every launch; debug builds skip it so a
        // console change can be tested without waiting an hour.
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (error) {
      log('Remote Config fetch failed ($error) — using the last activated '
          'values, or the defaults');
    }
  }

  /// Which kind of update, if any, the numbers call for.
  ///
  /// Pure and parameterised so the three rules can be exercised without a
  /// Firebase app. A non-positive [currentBuild] means the platform did not
  /// report a usable build number, which must never be read as "older than
  /// everything"; a non-positive Remote Config value means the parameter is
  /// unset, and an unset parameter never triggers a prompt.
  @visibleForTesting
  static AppUpdateRequirement requirementFor({
    required int currentBuild,
    required int latestBuild,
    required int minimumBuild,
  }) {
    if (currentBuild <= 0) return AppUpdateRequirement.none;
    if (minimumBuild > 0 && currentBuild < minimumBuild) {
      return AppUpdateRequirement.mandatory;
    }
    if (latestBuild > 0 && currentBuild < latestBuild) {
      return AppUpdateRequirement.optional;
    }
    return AppUpdateRequirement.none;
  }

  /// The https store listing for [platform], or an empty string when there is
  /// nothing safe to open — which suppresses the prompt entirely.
  @visibleForTesting
  static String storeUrlFor({
    required TargetPlatform platform,
    required String configuredPlayUrl,
    required String configuredAppStoreUrl,
    required String packageName,
  }) {
    switch (platform) {
      case TargetPlatform.android:
        final configured = configuredPlayUrl.trim();
        if (configured.isNotEmpty) return configured;
        // Derived from the running app's own id rather than hard-coded, so it
        // stays correct if the application id ever changes.
        return 'https://play.google.com/store/apps/details?id=$packageName';
      case TargetPlatform.iOS:
        // Never Google Play. There is no id-derived App Store URL either —
        // the numeric Apple id is not knowable from the bundle — so without
        // the console value the check stays silent.
        return configuredAppStoreUrl.trim();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
    }
  }

  /// The scheme that hands the user straight to the installed store app.
  @visibleForTesting
  static String? nativeStoreUrlFor({
    required TargetPlatform platform,
    required String storeUrl,
    required String packageName,
  }) {
    switch (platform) {
      case TargetPlatform.android:
        return 'market://details?id=$packageName';
      case TargetPlatform.iOS:
        return storeUrl.startsWith('https://')
            ? storeUrl.replaceFirst('https://', 'itms-apps://')
            : null;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return null;
    }
  }
}
