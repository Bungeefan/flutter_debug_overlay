import 'package:flutter/material.dart';

import '../util/split_page.dart';
import 'action/action_page.dart';
import 'action/debug_action.dart';
import 'value/debug_value.dart';
import 'value/value_page.dart';

class ActionValuePage extends StatelessWidget {
  final List<DebugAction> actions;
  final List<DebugValue> values;

  const ActionValuePage({
    super.key,
    required this.actions,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return ValuePage(entries: values);
    } else if (values.isEmpty) {
      return ActionPage(entries: actions);
    }

    return SplitPage(
      mainBuilder: _buildMain,
      detailBuilder: _buildDetail,
    );
  }

  Widget _buildMain(BuildContext context, bool split) {
    if (split) {
      return ActionPage(entries: actions);
    } else {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ActionPage(entries: actions),
            ),
          ),
          const Divider(
            height: 30,
            thickness: 3,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ValuePage(entries: values),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDetail(BuildContext context) {
    return ValuePage(entries: values);
  }
}
