import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  final List<Widget> entries;

  const DebugPage({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          "No entries",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey(entries),
      itemCount: entries.length,
      itemBuilder: (context, index) => entries[index],
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
