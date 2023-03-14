import 'package:flutter/material.dart';

import 'debug_value.dart';

class ValuePage extends StatelessWidget {
  final List<DebugValue> entries;

  const ValuePage({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        DebugValue? debugValue = entries[index];
        return ListTile(
          title: Text("${debugValue.name}:"),
          trailing: ValueListenableBuilder(
            valueListenable: debugValue.listenable,
            builder: (context, value, child) {
              return debugValue.builder?.call(context, value, child) ??
                  Text("$value");
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
