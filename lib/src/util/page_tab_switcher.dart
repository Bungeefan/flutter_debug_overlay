import 'package:flutter/material.dart';

import 'page_tabs.dart';

class PageTabSwitcher extends StatefulWidget {
  final Widget? subHeader;
  final Map<String, Widget> items;
  final WidgetBuilder? placeholderBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final int initialIndex;
  final ScrollPhysics? physics;
  final double horizontalPadding;

  const PageTabSwitcher({
    super.key,
    this.subHeader,
    required this.items,
    this.placeholderBuilder,
    this.controller,
    this.onPageChanged,
    this.initialIndex = 0,
    this.physics,
    this.horizontalPadding = 12.0,
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
      subHeader: widget.subHeader,
      onTabPressed: onTabPressed,
      onPageChanged: onPageChanged,
      controller: controller,
      currentItem: currentItem,
      items: widget.items,
      placeholderBuilder: widget.placeholderBuilder,
      physics: widget.physics,
      horizontalPadding: widget.horizontalPadding,
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
