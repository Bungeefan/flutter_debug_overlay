import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final GestureTapCallback? onTap;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const DataCard({
    super.key,
    this.onTap,
    this.constraints,
    this.padding = const EdgeInsets.all(16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: Theme.of(context).useMaterial3 ? null : 0.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
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
