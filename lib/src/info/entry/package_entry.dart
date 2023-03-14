import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../debug_info_entry.dart';
import '../properties.dart';

class PackageInfoEntry extends StatelessWidget {
  const PackageInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugInfoEntry(
      title: const Text("Package Info"),
      data: _retrieveInfo(),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo() async {
    final info = await PackageInfo.fromPlatform();
    return [
      DebugStringProperty(
        "App Name",
        info.appName,
        tooltip: "CFBundleDisplayName on iOS, application/label on Android.",
      ),
      DebugStringProperty(
        "Package Name",
        info.packageName,
        tooltip: "bundleIdentifier on iOS, getPackageName on Android.",
      ),
      DebugStringProperty(
        "Version",
        info.version,
        tooltip: "CFBundleShortVersionString on iOS, versionName on Android.",
      ),
      DebugStringProperty(
        "Build Number",
        info.buildNumber,
        tooltip: "CFBundleVersion on iOS, versionCode on Android.",
      ),
      DebugStringProperty(
        "Build Signature",
        info.buildSignature,
        tooltip: "Empty string on iOS, signing key signature (hex) on Android.",
      ),
      DebugStringProperty(
        "Installer Store",
        info.installerStore,
        ifNull: "unknown",
        tooltip:
            "Indicates through which store this application was installed.",
      ),
    ];
  }
}
