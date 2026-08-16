import 'package:flutter_json/flutter_json.dart';
import 'package:material_ui/material_ui.dart';

import '../../util/expandable_card.dart';
import '../../util/utils.dart';

class DataItem extends StatelessWidget {
  const DataItem({
    super.key,
    required this.title,
    this.expanded = true,
    required this.data,
    this.controller,
    this.initialExpandDepth = 1,
    this.hiddenKeys = const [],
  });

  final Widget title;
  final bool expanded;
  final dynamic data;
  final JsonController? controller;
  final int initialExpandDepth;
  final List<String> hiddenKeys;

  @override
  Widget build(BuildContext context) {
    bool showAsJson = data is Map || data is Iterable;

    return ExpandableCard(
      title: title,
      expanded: expanded,
      actions: [
        if (showAsJson && controller != null)
          IconButton(
            iconSize: 17,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.unfold_more),
            tooltip: "Expand All",
            onPressed: () => controller?.expandAllNodes(),
          ),
        if (showAsJson && controller != null)
          IconButton(
            iconSize: 17,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.unfold_less),
            tooltip: "Collapse All",
            onPressed: () => controller?.collapseAllNodes(),
          ),
      ],
      child: data != null && (data is! String || data.isNotEmpty)
          ? (showAsJson
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: JsonWidget(
                    controller: controller,
                    json: data,
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
                  child: SelectableText(data.toString()),
                ))
          : null,
    );
  }
}
