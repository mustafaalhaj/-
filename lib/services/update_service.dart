import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class UpdateService {
  // 🔴 IMPORTANT: Replace with your actual RAW GitHub URL
  static const String _updateUrl =
      'https://raw.githubusercontent.com/mustafaalhaj/ana-muslim-config/refs/heads/main/app_update.json';

  /// Check for updates
  /// Returns a Map with update info if available, or null if no update needed
  static Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      debugPrint('Checking for updates... Current version: $currentVersion');

      final response = await http.get(Uri.parse(_updateUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String latestVersion = data['latest_version'];
        final bool forceUpdate = data['force_update'] ?? false;
        final String downloadUrl = data['download_url'];

        if (_isNewVersion(currentVersion, latestVersion)) {
          debugPrint('New version available: $latestVersion');
          return {
            'latest_version': latestVersion,
            'force_update': forceUpdate,
            'download_url': downloadUrl,
            'current_version': currentVersion,
          };
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  /// Compare semantic versions (e.g. 1.0.0 vs 1.0.1)
  static bool _isNewVersion(String current, String latest) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> latestParts = latest.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length; i++) {
        // If current has fewer parts, assume 0 (e.g. 1.0 vs 1.0.1)
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        int latestPart = latestParts[i];

        if (latestPart > currentPart) return true;
        if (latestPart < currentPart) return false;
      }
      return false; // Equal
    } catch (e) {
      // Fallback for non-semantic versions
      return current != latest;
    }
  }
}
