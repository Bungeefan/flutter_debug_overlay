import 'package:flutter/material.dart';

import '../../util/data_card.dart';
import '../../util/expandable_card.dart';
import '../../util/switcher_widget.dart';
import '../http_interaction.dart';
import 'error_page.dart';
import 'request_page.dart';
import 'response_page.dart';

class HttpLogDetailsPage extends StatefulWidget {
  final HttpInteraction entry;
  final List<String> hiddenFields;

  const HttpLogDetailsPage({
    super.key,
    required this.entry,
    this.hiddenFields = const [],
  });

  @override
  State<HttpLogDetailsPage> createState() => _HttpLogDetailsPageState();
}

class _HttpLogDetailsPageState extends State<HttpLogDetailsPage> {
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
                          widget.entry.method?.toUpperCase() ?? "-",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.cyan.shade700,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          "METHOD",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: Column(
                      children: [
                        SelectableText(
                          widget.entry.duration?.inMilliseconds.toString() ??
                              "-",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: widget.entry.durationColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          "ms",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 100),
                    child: Column(
                      children: [
                        SelectableText(
                          widget.entry.response?.statusCode.toString() ??
                              (widget.entry.error != null ? "ERROR" : "-"),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: widget.entry.error != null
                                        ? Colors.red
                                        : widget.entry.statusColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          "STATUS",
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
        title: Text(
          widget.entry.uri?.toString() ?? "-",
          overflow: TextOverflow.ellipsis,
        ),
        useOnlyButton: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              widget.entry.uri?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            SelectableText.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Request time: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.entry.request?.time?.toString() ?? "-"),
                ],
              ),
            ),
            SelectableText.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Response time: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: widget.entry.response?.time?.toString() ?? "-"),
                ],
              ),
            ),
            if (widget.entry.error?.time != null)
              SelectableText.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Error time: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.entry.error!.time.toString()),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];

    return SwitcherWidget(
      physics: !Theme.of(context).useMaterial3
          ? const BouncingScrollPhysics()
          : null,
      items: {
        "Request": RequestPage(
          httpInteraction: widget.entry,
          hiddenFields: widget.hiddenFields,
          children: children,
        ),
        if (widget.entry.response != null)
          "Response": ResponsePage(
            httpInteraction: widget.entry,
            hiddenFields: widget.hiddenFields,
            children: children,
          ),
        if (widget.entry.error?.containsData() ?? false)
          "Error": ErrorPage(
            httpInteraction: widget.entry,
            hiddenFields: widget.hiddenFields,
            children: children,
          ),
      },
    );
  }
}
