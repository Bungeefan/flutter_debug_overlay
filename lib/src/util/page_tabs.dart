import 'dart:math';

import 'package:flutter/material.dart';

class PageTabs extends StatelessWidget {
  final Map<String, Widget> items;
  final PageController controller;
  final int currentItem;
  final ValueChanged<int> onTabPressed;
  final ValueChanged<int> onPageChanged;
  final ScrollPhysics? physics;
  final double horizontalPadding;
  final Widget? child;

  const PageTabs({
    super.key,
    required this.items,
    required this.currentItem,
    required this.controller,
    required this.onTabPressed,
    required this.onPageChanged,
    this.physics,
    this.horizontalPadding = 12.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    List<bool> selected;
    final int page = currentItem;

    selected = [
      for (int i = 0; i < items.length; i++) i == page,
    ];

    return Column(
      children: [
        if (items.length > 1)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                    onPressed: (index) => onTabPressed.call(index),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    constraints: BoxConstraints(
                      minWidth: max(
                        48.0,
                        (constraints.maxWidth) / items.length,
                      ),
                      minHeight: double.infinity,
                    ),
                    renderBorder: false,
                    isSelected: selected,
                    selectedColor: Theme.of(context).colorScheme.onPrimary,
                    fillColor: Theme.of(context).colorScheme.primary,
                    children: [
                      for (String itemName in items.keys)
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
        if (child != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: child!,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: PageView.builder(
              physics: physics,
              controller: controller,
              onPageChanged: (index) => onPageChanged.call(index),
              itemCount: items.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: items.values.toList()[index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
