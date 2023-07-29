import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/src/util/page_tabs.dart';

class PageTabSwitcher extends StatefulWidget {
  final Map<String, Widget> items;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final int initialIndex;
  final ScrollPhysics? physics;
  final double horizontalPadding;
  final Widget? child;

  const PageTabSwitcher({
    super.key,
    required this.items,
    this.controller,
    this.onPageChanged,
    this.initialIndex = 0,
    this.physics,
    this.horizontalPadding = 12.0,
    this.child,
  });

  @override
  State<PageTabSwitcher> createState() => PageTabSwitcherState();
}

class PageTabSwitcherState extends State<PageTabSwitcher> {
  late int currentItem;
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    currentItem = widget.initialIndex;
    if (widget.controller == null) {
      pageController = PageController(initialPage: currentItem);
    }
  }

  PageController get controller => widget.controller ?? pageController!;

  @override
  void didUpdateWidget(covariant PageTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (currentItem >= widget.items.length) {
      currentItem = widget.initialIndex;
      controller.jumpToPage(currentItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTabs(
      onTabPressed: onTabPressed,
      onPageChanged: onPageChanged,
      controller: controller,
      currentItem: currentItem,
      items: widget.items,
      physics: widget.physics,
      horizontalPadding: widget.horizontalPadding,
      child: widget.child,
    );
  }

  void onTabPressed(int index) {
    controller.jumpToPage(index);
    onPageChanged(index);
    // controller.animateToPage(
    //   index,
    //   duration: kThemeAnimationDuration,
    //   curve: Curves.easeInOut,
    // );
  }

  void onPageChanged(int index) {
    currentItem = index;
    setState(() {});
    widget.onPageChanged?.call(index);
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }
}
