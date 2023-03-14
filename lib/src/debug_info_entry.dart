import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'debug_overlay.dart';
import 'info/entry/device_entry.dart';
import 'info/entry/media_query_entry.dart';
import 'info/info_card.dart';
import 'info/properties.dart';

/// Represents the basis for a a info entry used in [DebugOverlay.infoEntries].
///
/// See also:
/// * [DeviceInfoEntry]
/// * [MediaQueryInfoEntry]
/// * [PackageInfoEntry]
/// * [PlatformInfoEntry]
class DebugInfoEntry extends StatelessWidget {
  static const double _kChildrenPadding = 6.0;

  const DebugInfoEntry({
    super.key,
    required this.title,
    required this.data,
  });

  final Widget title;
  final Future<List<DebugPropertyNode>> data;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      child: FutureBuilder<List<DebugPropertyNode>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              debugPrint("Error while collecting data: ${snapshot.error}");
              debugPrintStack(stackTrace: snapshot.stackTrace);
            }

            return Text("${snapshot.error}\n${snapshot.stackTrace!}");
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isNotEmpty) {
            return Column(
              children: buildChildren(snapshot.data!),
            );
          } else {
            return Center(
              child: Text(
                "Empty",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> buildChildren(
    List<DebugPropertyNode> children, [
    double leftPadding = 0.0,
  ]) {
    List<Widget> widgets = [];

    for (var child in children) {
      String? name = child.name;
      String description = child.toDescription().trimRight();
      bool wrapDescription =
          description.contains("\n") || description.length >= 120;

      var nextChildren = buildChildren(child.getChildren(), _kChildrenPadding);

      Widget wrapTooltip(Widget child, {String? tooltip}) {
        if (tooltip != null) {
          return Tooltip(
            message: tooltip,
            child: child,
          );
        }
        return child;
      }

      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: leftPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (child.showName && name != null)
                      wrapTooltip(
                        SelectableText(
                          child.showSeparator ? "$name:" : name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        tooltip: child.tooltip,
                      ),
                    if (description.isNotEmpty && !wrapDescription)
                      Expanded(
                        child: wrapTooltip(
                          Padding(
                            padding: child.showName
                                ? const EdgeInsets.only(left: 4.0)
                                : EdgeInsets.zero,
                            child: SelectableText(description),
                          ),
                          tooltip: !child.showName || name == null
                              ? child.tooltip
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              if (wrapDescription)
                Padding(
                  padding: child.showName
                      ? const EdgeInsets.only(left: _kChildrenPadding)
                      : EdgeInsets.zero,
                  child: SelectableText(description),
                ),
              ...buildChildren(child.getProperties(), _kChildrenPadding),
              if (nextChildren.isNotEmpty)
                Column(
                  children: nextChildren,
                )
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}
