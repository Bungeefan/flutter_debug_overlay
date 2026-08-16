import 'package:flutter_json/flutter_json.dart';
import 'package:material_ui/material_ui.dart';

import '../../debug_overlay.dart';
import '../../util/debug_http_handler.dart';
import '../../util/expandable_card.dart';
import '../../util/utils.dart';

class BodyItem extends StatelessWidget {
  const BodyItem({
    super.key,
    this.title = const Text("Body"),
    this.expanded = true,
    this.headers,
    required this.body,
    this.controller,
    this.initialExpandDepth = 1,
    this.hiddenKeys = const [],
  });

  final Widget title;
  final bool expanded;
  final Map<String, dynamic>? headers;
  final dynamic body;
  final JsonController? controller;
  final int initialExpandDepth;
  final List<String> hiddenKeys;

  @override
  Widget build(BuildContext context) {
    BodyType type = DebugOverlay.httpHandler.determineBodyType(headers, body);

    return ExpandableCard(
      title: title,
      expanded: expanded,
      actions: buildActions(context, type),
      child: buildBodyDisplay(context, type),
    );
  }

  List<Widget> buildActions(BuildContext context, BodyType type) {
    return [
      if (type == BodyType.json && controller != null)
        IconButton(
          iconSize: 17,
          splashRadius: 20,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.unfold_more),
          tooltip: "Expand All",
          onPressed: () => controller?.expandAllNodes(),
        ),
      if (type == BodyType.json && controller != null)
        IconButton(
          iconSize: 17,
          splashRadius: 20,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.unfold_less),
          tooltip: "Collapse All",
          onPressed: () => controller?.collapseAllNodes(),
        ),
    ];
  }

  Widget? buildBodyDisplay(BuildContext context, BodyType type) {
    switch (type) {
      case BodyType.empty:
        return null;
      case BodyType.custom:
        return DebugOverlay.httpHandler
            .buildCustomBody(context, headers, body, hiddenKeys);
      case BodyType.json:
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 350),
          child: JsonWidget(
            controller: controller,
            json: body,
            initialExpandDepth: initialExpandDepth,
            hiddenKeys: hiddenKeys,
            keyColor: Theme.of(context).colorScheme.primary,
            hiddenColor: Theme.of(context).colorScheme.primary,
            onLongPress: (node) {
              Utils.copyToClipboard(
                context,
                value: Utils.encodePrettyJson(node),
                title: "JSON",
              );
            },
          ),
        );
      case BodyType.raw:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(body.toString()),
        );
    }
  }
}
