import 'package:flutter/material.dart';

import '../../util/data_card.dart';
import '../../util/expandable_card.dart';
import '../log_event.dart';

class LogDetailsPage extends StatefulWidget {
  final LogEvent entry;

  const LogDetailsPage({
    super.key,
    required this.entry,
  });

  @override
  State<LogDetailsPage> createState() => _LogDetailsPageState();
}

class _LogDetailsPageState extends State<LogDetailsPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      DataCard(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 100),
                    child: Column(
                      children: [
                        SelectableText(
                          widget.entry.level.name.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: widget.entry.levelColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          "LEVEL",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200),
                    child: Column(
                      children: [
                        SelectableText(
                          widget.entry.time.toString(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          "TIME",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      ExpandableCard(
        title: const Text("Message"),
        expanded: true,
        expandable: false,
        child: SelectableText(widget.entry.message),
      ),
      if (widget.entry.error != null)
        ExpandableCard(
          title: const Text("Error"),
          expanded: true,
          child: SelectableText(widget.entry.error.toString()),
        ),
      if (widget.entry.stackTrace != null)
        ExpandableCard(
          title: const Text("Stack Trace"),
          expanded: true,
          child: widget.entry.stackTrace.toString().trim().isNotEmpty
              ? SelectableText(widget.entry.stackTrace.toString().trim())
              : null,
        ),
    ];

    return ListView.separated(
      physics: !Theme.of(context).useMaterial3
          ? const BouncingScrollPhysics()
          : null,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}
