import 'package:flutter/material.dart';

import '../../util/expandable_card.dart';
import '../../util/utils.dart';
import '../enumeration_points.dart';

class ParameterItem extends StatelessWidget {
  final Map<String, dynamic>? parameters;
  final List<String> hiddenFields;

  const ParameterItem(
    this.parameters, {
    super.key,
    this.hiddenFields = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: const Text("Parameters"),
      child: parameters != null && parameters!.isNotEmpty
          ? EnumerationPoints(
              parameters!,
              hiddenFields: hiddenFields,
              onLongPress: (entry) => Utils.copyToClipboard(
                context,
                title: '"${entry.key}" Parameter',
                value: "${entry.key}: ${entry.value}",
              ),
            )
          : null,
    );
  }
}
