import 'dart:io';

import 'package:flutter/foundation.dart';
import "package:flutter/widgets.dart";

import '../../debug_info_entry.dart';
import '../properties.dart';

class PlatformInfoEntry extends StatelessWidget {
  const PlatformInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    assert(!kIsWeb, "This debug widget is not supported on dart.library.html");

    return DebugInfoEntry(
      title: const Text("Platform Info"),
      data: _retrieveInfo(),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo() async {
    return [
      DebugStringProperty("OS", Platform.operatingSystem),
      DebugStringProperty("OS Version", Platform.operatingSystemVersion),
      DebugStringProperty("Version", Platform.version),
      DebugStringProperty("Locale", Platform.localeName),
      DebugStringProperty("Hostname", Platform.localHostname),
      DebugIntProperty("Number of CPUs", Platform.numberOfProcessors),
      DebugStringProperty(
        "Package Config",
        Platform.packageConfig ?? "No flag specified",
        tooltip:
            "The --packages flag passed to the executable used to run the script in this isolate.",
      ),
      DebugStringProperty("Path Separator", Platform.pathSeparator),
      DebugStringProperty("Executable", Platform.executable),
      DebugStringProperty("Resolved Executable", Platform.resolvedExecutable),
      DebugBlock(
        name: "Environment Variables",
        properties: Platform.environment.entries
            .map((entry) => DebugStringProperty(entry.key, entry.value))
            .toList(),
      ),
      DebugIterableProperty(
        "Executable Arguments",
        Platform.executableArguments,
      ),
    ];
  }
}
