import 'package:flutter/material.dart';

class DebugPage extends StatefulWidget {
  final List<Widget> entries;

  const DebugPage({
    super.key,
    required this.entries,
  });

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage>
    with AutomaticKeepAliveClientMixin {
  // Saves potential state in custom debug entries.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.entries.isEmpty) {
      return Center(
        child: Text(
          "No entries",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    return ListView.separated(
      itemCount: widget.entries.length,
      itemBuilder: (context, index) => widget.entries[index],
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
