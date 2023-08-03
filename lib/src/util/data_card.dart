import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final bool selected;
  final GestureTapCallback? onTap;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const DataCard({
    super.key,
    this.selected = false,
    this.onTap,
    this.constraints,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    Widget card = Card(
      elevation: themeData.useMaterial3 ? null : 0.0,
      color: selected ? themeData.colorScheme.secondaryContainer : null,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: selected
            ? BorderSide(color: themeData.colorScheme.secondary)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (constraints != null) {
      card = ConstrainedBox(
        constraints: constraints!,
        child: card,
      );
    }

    return card;
  }
}
