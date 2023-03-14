import 'dart:math';

import 'package:flutter/material.dart';

class SwitcherWidget extends StatefulWidget {
  final Map<String, Widget> items;
  final int initialIndex;
  final ScrollPhysics? physics;
  final double horizontalPadding;
  final Widget? child;

  const SwitcherWidget({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.physics,
    this.horizontalPadding = 12.0,
    this.child,
  });

  @override
  State<SwitcherWidget> createState() => _SwitcherWidgetState();
}

class _SwitcherWidgetState extends State<SwitcherWidget> {
  late int currentItem;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    currentItem = widget.initialIndex;
    pageController = PageController(initialPage: currentItem);
  }

  @override
  void didUpdateWidget(covariant SwitcherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (currentItem >= widget.items.length) {
      currentItem = widget.initialIndex;
      pageController.jumpToPage(currentItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<bool> selected;
    final int page = currentItem;

    selected = [
      for (int i = 0; i < widget.items.length; i++) i == page,
    ];

    return Column(
      children: [
        if (widget.items.length > 1)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  height: 40,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(20),
                    onPressed: (index) async {
                      currentItem = index;
                      setState(() {});
                      pageController.jumpToPage(index);
                      // pageController.animateToPage(
                      //   index,
                      //   duration: kThemeAnimationDuration,
                      //   curve: Curves.easeInOut,
                      // );
                    },
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    constraints: BoxConstraints(
                      minWidth: max(
                        48.0,
                        (constraints.maxWidth) / widget.items.length,
                      ),
                      minHeight: double.infinity,
                    ),
                    renderBorder: false,
                    isSelected: selected,
                    selectedColor: Theme.of(context).colorScheme.onPrimary,
                    fillColor: Theme.of(context).colorScheme.primary,
                    children: [
                      for (String itemName in widget.items.keys)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(itemName),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        if (widget.child != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: widget.child!,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: PageView.builder(
              physics: widget.physics,
              controller: pageController,
              onPageChanged: (index) {
                currentItem = index;
                setState(() {});
              },
              itemCount: widget.items.length,
              itemBuilder: (context, index) => Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                child: widget.items.values.toList()[index],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
