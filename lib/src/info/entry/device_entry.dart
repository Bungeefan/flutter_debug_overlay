import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/widgets.dart";

import '../../debug_info_entry.dart';
import '../properties.dart';

class DeviceInfoEntry extends StatelessWidget {
  const DeviceInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugInfoEntry(
      title: const Text("Device Info"),
      data: _retrieveInfo(),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo() async {
    if (kIsWeb) return _retrieveWebInfo();
    if (Platform.isAndroid) return _retrieveAndroidInfo();
    if (Platform.isIOS) return _retrieveiOSInfo();
    if (Platform.isWindows) return _retrieveWindowsInfo();
    if (Platform.isLinux) return _retrieveLinuxInfo();
    if (Platform.isMacOS) return _retrieveMacOSInfo();
    if (Platform.isFuchsia) return [DebugStringProperty("OS", "Fuchsia")];
    return [
      DebugStringProperty("OS", Platform.operatingSystem),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveWebInfo() async {
    final info = await DeviceInfoPlugin().webBrowserInfo;
    return [
      DebugBlock(
        name: "Browser: ${info.browserName.name}",
        properties: [
          DebugStringProperty(
            "Vendor",
            info.vendor,
          ),
          DebugStringProperty(
            "Vendor Version",
            info.vendorSub,
            defaultValue: "",
          ),
          DebugStringProperty(
            "Codename",
            info.appCodeName,
          ),
          DebugStringProperty(
            "Version",
            info.appVersion,
          ),
          DebugStringProperty(
            "Build Number",
            info.productSub,
          ),
        ],
      ),
      DebugStringProperty("Language", info.language),
      DebugIterableProperty("Languages", info.languages),
      DebugStringProperty("User Agent", info.userAgent),
      DebugIntProperty(
        "Maximum Simultaneous Touch Points",
        info.maxTouchPoints,
        defaultValue: 0,
      ),
      DebugIntProperty("Logical CPU Cores", info.hardwareConcurrency),
      DebugDoubleProperty(
        "Memory Size (GB)",
        info.deviceMemory?.toDouble(),
        ifNull: "unknown",
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveAndroidInfo() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return [
      DebugBlock(
        name: "Android",
        properties: [
          DebugStringProperty("Build Type", info.type),
          DebugStringProperty("Build Tags", info.tags),
          DebugStringProperty(
            "Fingerprint",
            info.fingerprint,
          ),
          DebugIterableProperty(
            "Supported 32-Bit ABIs",
            info.supported32BitAbis,
          ),
          DebugIterableProperty(
            "Supported 64-Bit ABIs",
            info.supported64BitAbis,
          ),
          DebugIterableProperty(
            "Supported ABIs",
            info.supportedAbis,
          ),
          DebugIterableProperty(
            "System Features",
            info.systemFeatures,
          ),
        ],
        children: [
          DebugBlock(
            name: "Version",
            properties: [
              DebugStringProperty("Version", info.version.release),
              DebugIntProperty(
                "SDK Version",
                info.version.sdkInt,
                defaultValue: -1,
              ),
              DebugIntProperty(
                "Developer Preview SDK",
                info.version.previewSdkInt,
                ifNull: "-",
              ),
              DebugStringProperty(
                "Base OS Build",
                info.version.baseOS,
                defaultValue: "",
              ),
              DebugStringProperty(
                "Security Patch",
                info.version.securityPatch,
                defaultValue: "",
              ),
              DebugStringProperty(
                "Codename",
                info.version.codename,
                defaultValue: "REL",
              ),
              DebugStringProperty(
                "Incremental",
                info.version.incremental,
              ),
            ],
          ),
        ],
      ),
      DebugBlock(
        name: "Device",
        properties: [
          DebugFlagProperty(
            "Is a physical device?",
            value: info.isPhysicalDevice,
            ifTrue: "Running on a physical device",
            ifFalse: "Running on an emulator or unknown device",
          ),
          DebugStringProperty("Board", info.board),
          DebugStringProperty("Manufacturer", info.manufacturer),
          DebugStringProperty("Brand", info.brand),
          DebugStringProperty("Product", info.product),
          DebugStringProperty("Device", info.device),
          DebugStringProperty("Model", info.model),
          DebugStringProperty("Bootloader", info.bootloader),
          DebugStringProperty("Hardware", info.hardware),
          DebugStringProperty("Hostname", info.host),
          DebugStringProperty("Changelist Number / Label", info.id),
        ],
        children: [
          DebugStringProperty(
            "Display Build ID",
            info.display,
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveiOSInfo() async {
    final info = await DeviceInfoPlugin().iosInfo;
    return [
      DebugBlock(
        name: "iOS",
        properties: [
          DebugStringProperty("Name", info.systemName),
          DebugStringProperty("Version", info.systemVersion),
        ],
        children: [
          DebugBlock(
            name: "utsname",
            properties: [
              DebugStringProperty("Name", info.utsname.sysname),
              DebugStringProperty("Network Node Name", info.utsname.nodename),
              DebugStringProperty("Release Level", info.utsname.release),
              DebugStringProperty("Version Level", info.utsname.version),
              DebugStringProperty("Hardware Type", info.utsname.machine),
            ],
          ),
        ],
      ),
      DebugBlock(
        name: "Device",
        properties: [
          DebugFlagProperty(
            "Is a physical device?",
            value: info.isPhysicalDevice,
            ifTrue: "Running on a physical device",
            ifFalse: "Running on a simulator or unknown device",
          ),
          DebugStringProperty("Name", info.name),
          DebugStringProperty("Model", info.model),
          DebugStringProperty("Model (localized)", info.localizedModel),
          DebugStringProperty(
            "Identifier for the Vendor",
            info.identifierForVendor,
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveWindowsInfo() async {
    final info = await DeviceInfoPlugin().windowsInfo;
    return [
      DebugBlock(
        name: "Windows",
        children: [
          DebugStringProperty(
            "Computer Name",
            info.computerName,
            defaultValue: "",
          ),
          DebugIntProperty("Core Count", info.numberOfCores),
          DebugStringProperty(
            "Memory Size (MB)",
            "${(info.systemMemoryInMegabytes)}",
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveLinuxInfo() async {
    final info = await DeviceInfoPlugin().linuxInfo;
    return [
      DebugBlock(
        name: info.prettyName,
        children: [
          DebugStringProperty(
            "ID",
            info.id,
            defaultValue: "linux",
          ),
          DebugIterableProperty("ID-like", info.idLike),
          DebugStringProperty("Version", info.version, defaultValue: null),
          DebugStringProperty("Version ID", info.versionId, defaultValue: null),
          DebugStringProperty(
            "Version Codename",
            info.versionCodename,
            defaultValue: null,
          ),
          DebugStringProperty("Build ID", info.buildId, defaultValue: null),
          DebugStringProperty("Variant", info.variant, defaultValue: null),
          DebugStringProperty(
            "Variant ID",
            info.variantId,
            defaultValue: null,
          ),
          DebugStringProperty(
            "Machine ID",
            info.machineId,
            defaultValue: null,
          ),
        ],
      ),
    ];
  }

  static Future<List<DebugPropertyNode>> _retrieveMacOSInfo() async {
    final info = await DeviceInfoPlugin().macOsInfo;
    return [
      DebugBlock(
        name: "macOS",
        children: [
          DebugStringProperty("OS Release", info.osRelease),
          DebugStringProperty(
            "Kernel Version",
            info.kernelVersion,
          ),
          DebugStringProperty("Architecture", info.arch),
          DebugStringProperty("Device Model", info.model),
          DebugStringProperty("Computer Name", info.computerName),
          DebugStringProperty("Host Name", info.hostName),
          DebugIntProperty("Active CPUs", info.activeCPUs),
          DebugStringProperty(
            "Memory Size",
            "${info.memorySize}",
          ),
          DebugStringProperty(
            "CPU Frequency",
            "${info.cpuFrequency}Hz",
          ),
        ],
      ),
    ];
  }
}
