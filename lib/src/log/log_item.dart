import 'package:flutter/material.dart';

import '../util/data_card.dart';
import '../util/utils.dart';
import 'log_event.dart';

class LogItem extends StatelessWidget {
  final LogEvent entry;
  final void Function() onSelected;

  const LogItem({
    super.key,
    required this.entry,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    MaterialColor effectiveLevelColor = entry.levelColor;

    return DataCard(
      onTap: onSelected,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: effectiveLevelColor.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 51),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Text(
                      entry.level.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: effectiveLevelColor.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: "Copy message",
                onPressed: () {
                  Utils.copyToClipboard(context, value: entry.message);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              entry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Text(entry.time.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
