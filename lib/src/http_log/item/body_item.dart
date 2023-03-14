import 'package:flutter/material.dart';
import 'package:flutter_json/flutter_json.dart';

import '../../util/expandable_card.dart';
import '../../util/utils.dart';

class BodyItem extends StatelessWidget {
  const BodyItem({
    super.key,
    this.title = const Text("Body"),
    this.expanded = true,
    required this.body,
    this.controller,
    this.initialExpandDepth = 1,
    this.hiddenKeys = const [],
  });

  final Widget title;
  final bool expanded;
  final dynamic body;
  final JsonController? controller;
  final int initialExpandDepth;
  final List<String> hiddenKeys;

  @override
  Widget build(BuildContext context) {
    bool isJson = body is Map || body is Iterable;
    return ExpandableCard(
      title: title,
      expanded: expanded,
      actions: [
        if (isJson && controller != null)
          IconButton(
            iconSize: 17,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.unfold_more),
            tooltip: "Expand All",
            onPressed: () => controller?.expandAllNodes(),
          ),
        if (isJson && controller != null)
          IconButton(
            iconSize: 17,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.unfold_less),
            tooltip: "Collapse All",
            onPressed: () => controller?.collapseAllNodes(),
          ),
      ],
      child: body != null && (body is! String || body.isNotEmpty)
          ? (isJson
              ? ConstrainedBox(
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
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(body.toString()),
                ))
          : null,
    );
  }
}
