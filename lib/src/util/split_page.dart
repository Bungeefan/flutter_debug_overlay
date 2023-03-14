import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

class SplitPage extends StatefulWidget {
  final double widthThreshold;
  final List<WeightLimit>? limits;
  final void Function(bool split)? onSplitChange;
  final Widget Function(BuildContext context, bool split) mainBuilder;
  final WidgetBuilder detailBuilder;

  const SplitPage({
    super.key,
    this.widthThreshold = 1100,
    this.limits,
    this.onSplitChange,
    required this.mainBuilder,
    required this.detailBuilder,
  });

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  bool? lastSplit;
  late final SplitViewController _splitViewController;

  @override
  void initState() {
    super.initState();
    _splitViewController = SplitViewController(
      limits: widget.limits ??
          [
            WeightLimit(min: 0.35),
            WeightLimit(min: 0.35),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool split = constraints.maxWidth > widget.widthThreshold;
        if (split != lastSplit) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            widget.onSplitChange?.call(split);
          });
        }
        lastSplit = split;
        Widget main = widget.mainBuilder.call(context, split);

        if (split) {
          Widget detail = widget.detailBuilder.call(context);

          return SplitView(
            controller: _splitViewController,
            gripSize: 30,
            gripColor: Colors.transparent,
            gripColorActive: Colors.transparent,
            viewMode: SplitViewMode.Horizontal,
            indicator: const SplitIndicator(
              viewMode: SplitViewMode.Horizontal,
              color: Colors.grey,
            ),
            activeIndicator: SplitIndicator(
              viewMode: SplitViewMode.Horizontal,
              isActive: true,
              color: Theme.of(context).colorScheme.primary,
            ),
            children: [
              main,
              detail,
            ],
          );
        } else {
          return main;
        }
      },
    );
  }

  @override
  void dispose() {
    _splitViewController.dispose();
    super.dispose();
  }
}
