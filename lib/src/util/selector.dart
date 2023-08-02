import 'package:flutter/material.dart';

class Selector<T> extends StatelessWidget {
  final String? tooltip;
  final bool useIcons;
  final T? selectedValue;
  final Map<String, T?> values;
  final ValueSetter<T> onSelected;
  final Widget Function(String key, T value) valueBuilder;
  final double iconSize;
  final double splashRadius;

  const Selector({
    super.key,
    this.tooltip,
    this.useIcons = true,
    this.selectedValue,
    required this.values,
    required this.onSelected,
    required this.valueBuilder,
    this.iconSize = 32,
    this.splashRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      initialValue: selectedValue,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (var entry in values.entries)
          PopupMenuItem<T>(
            value: entry.value,
            child: Text(entry.key),
          ),
      ],
      padding: EdgeInsets.zero,
      iconSize: iconSize,
      splashRadius: splashRadius,
      icon: useIcons ? _buildChild() : null,
      child: !useIcons ? _buildChild() : null,
    );
  }

  Widget _buildChild() {
    return selectedValue == null
        ? const Text("-")
        : valueBuilder(
            values.entries
                .where((e) => e.value == selectedValue)
                .map((e) => e.key)
                .first,
            selectedValue as T,
          );
  }
}
