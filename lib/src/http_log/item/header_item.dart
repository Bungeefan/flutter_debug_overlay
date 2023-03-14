import 'package:flutter/material.dart';

import '../../util/expandable_card.dart';
import '../../util/utils.dart';
import '../enumeration_points.dart';

class HeaderItem extends StatelessWidget {
  final Map<String, dynamic>? headers;
  final List<String> hiddenFields;

  const HeaderItem(
    this.headers, {
    super.key,
    this.hiddenFields = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: const Text("Headers"),
      child: headers != null && headers!.isNotEmpty
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: EnumerationPoints(
                headers!,
                hiddenFields: hiddenFields,
                onLongPress: (entry) => Utils.copyToClipboard(
                  context,
                  title: '"${entry.key}" Header',
                  value: "${entry.key}: ${entry.value}",
                ),
              ),
            )
          : null,
    );
  }
}
