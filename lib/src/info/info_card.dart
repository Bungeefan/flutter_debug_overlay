import 'package:flutter/material.dart';

import '../util/data_card.dart';

class InfoCard extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget child;

  const InfoCard({
    super.key,
    required this.title,
    this.actions = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DataCard(
      padding: const EdgeInsets.only(
        left: 16,
        right: 4.5,
      ),
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
                    style: Theme.of(context).textTheme.titleLarge,
                    child: title,
                  ),
                ),
              ),
              ...actions,
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 16,
              right: 16 - 4.5,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
