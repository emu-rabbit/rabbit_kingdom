import 'dart:developer';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/popups/should_update_popup.dart';

class VersionService {
  static Future<void> checkUpdate() async {
    try {
      await _activateRemoteConfig();
      final appVersion = await _getAppVersion();
      final latestVersion = await _getLatestVersion();
      final minimalVersion= await _getMinimalVersion();
      debugPrint("appVersion: $appVersion, latestVersion: $latestVersion, minimalVersion: $minimalVersion");
      if (_isVersionLessThan(appVersion, minimalVersion)) {
        await Get.rPopup(
          ShouldUpdatePopup(
            type: UpdateType.force,
            appVersion: _toDisplayString(appVersion),
            latestVersion: _toDisplayString(latestVersion),
          )
        );
      } else if (_isVersionLessThan(appVersion, latestVersion)) {
        await Get.rPopup(
            ShouldUpdatePopup(
              type: UpdateType.optional,
              appVersion: _toDisplayString(appVersion),
              latestVersion: _toDisplayString(latestVersion),
            )
        );
      }
    } catch (e) {
      debugPrint("check update failed ${e.toString()}");
    }
  }

  static Future<void> _activateRemoteConfig() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await FirebaseRemoteConfig.instance.setConfigSettings(
          RemoteConfigSettings(
              fetchTimeout: const Duration(seconds: 30),
              minimumFetchInterval: kDebugMode ? const Duration(minutes: 1) : const Duration(minutes: 10)
          )
      );
      await FirebaseRemoteConfig.instance.fetchAndActivate();
    } else {
      throw Exception("Platform error");
    }
  }

  static Future<List<dynamic>> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return _parseVersion('${info.version}+${info.buildNumber}');
  }

  static Future<List<dynamic>> _getLatestVersion() async {
    final version = FirebaseRemoteConfig.instance.getString("latest_available_version_${Platform.isAndroid ? "android": "ios"}");
    if (version.isEmpty) throw Exception("Cannot get latest version");
    return _parseVersion(version);
  }

  static Future<List<dynamic>> _getMinimalVersion() async {
    final version = FirebaseRemoteConfig.instance.getString("minimal_supported_version_${Platform.isAndroid ? "android": "ios"}");
    if (version.isEmpty) throw Exception("Cannot get latest version");
    return _parseVersion(version);
  }

  // 輔助函數：解析版本號為可比較的形式 (例如 [1, 0, 5])
  static List<dynamic> _parseVersion(String version) {
    List<String> parts = version.split('+');
    List<int> mainVersion = parts[0].split('.').map(int.parse).toList();
    int buildNumber = parts.length > 1 ? int.parse(parts[1]) : 0; // 如果沒有 Build 號，預設為 0

    return [mainVersion, buildNumber];
  }
  static String _toDisplayString(List<dynamic> version) {
    if (version.length != 2 ||
        version[0] is! List<int> ||
        version[1] is! int) {
      throw ArgumentError(
          'Invalid parsedVersion format. Expected [[Major, Minor, Patch], Build].');
    }

    List<int> mainVersion = version[0];
    int buildNumber = version[1];

    // 將主要版本號部分組合成字串，例如 [1, 0, 0] -> "1.0.0"
    String mainVersionString = mainVersion.join('.');

    // 如果有 Build 號且不為 0，則加上 "+buildNumber"
    if (buildNumber > 0) {
      return '$mainVersionString+$buildNumber';
    } else {
      // 如果 Build 號為 0 或不存在，則只返回主要版本號
      return mainVersionString;
    }
  }

  // 輔助函數：比較版本號
  // current 和 target 都是由 _parseVersion 返回的 [[Major, Minor, Patch], Build] 格式
  static bool _isVersionLessThan(List<dynamic> current, List<dynamic> target) {
    List<int> currentMain = current[0];
    int currentBuild = current[1];
    List<int> targetMain = target[0];
    int targetBuild = target[1];

    // 1. 先比較主要版本號 (Major.Minor.Patch)
    for (int i = 0; i < currentMain.length; i++) {
      // 如果目標版本的主版本號段數比當前版本少，但前面都相同，則當前版本更高或相等
      // 例如 currentMain [1,0,0], targetMain [1,0] -> current >= target
      if (i >= targetMain.length) {
        // 如果當前主版本號比目標長，且前面都相同，那當前版本肯定更高
        return false;
      }
      if (currentMain[i] < targetMain[i]) {
        // 當前版本主號段小於目標，則當前版本更舊
        return true;
      }
      if (currentMain[i] > targetMain[i]) {
        // 當前版本主號段大於目標，則當前版本更新
        return false;
      }
    }

    // 2. 如果主要版本號完全相同，則比較 Build 號
    // 如果到這裡，currentMain 和 targetMain 是相等的
    return currentBuild < targetBuild;
  }
}