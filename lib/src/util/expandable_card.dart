import 'package:flutter/material.dart';

import 'data_card.dart';

class ExpandableCard extends StatefulWidget {
  final Widget title;
  final bool expandable;
  final bool expanded;
  final bool useOnlyButton;
  final List<Widget> actions;
  final Widget? child;

  const ExpandableCard({
    super.key,
    required this.title,
    this.expandable = true,
    this.expanded = false,
    this.useOnlyButton = true,
    this.actions = const [],
    this.child,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }

  @override
  void didUpdateWidget(covariant ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      expanded = widget.expanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataCard(
      padding: EdgeInsets.only(
        left: 16,
        right: widget.expandable && widget.child != null ? 4.5 : 16,
      ),
      onTap: !widget.useOnlyButton
          ? () {
              setState(() => expanded = !expanded);
            }
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                  ),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                    child: widget.title,
                  ),
                ),
              ),
              if (widget.child != null) ...widget.actions,
              if (widget.expandable && widget.child != null)
                widget.useOnlyButton
                    ? IconButton(
                        iconSize: 17,
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        tooltip: expanded ? "Collapse" : "Expand",
                        onPressed: () => setState(() => expanded = !expanded),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 17,
                        ),
                      ),
              if (widget.expandable && widget.child == null)
                const Text("Empty"),
            ],
          ),
          if (widget.child != null && expanded)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                right: 16 - 4.5,
              ),
              child: widget.child!,
            ),
        ],
      ),
    );
  }
}
