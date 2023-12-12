import 'package:flutter/material.dart';

import '../util/data_card.dart';
import '../util/utils.dart';
import 'http_interaction.dart';

class HttpLogItem extends StatelessWidget {
  final HttpInteraction entry;
  final bool selected;
  final void Function() onSelected;

  const HttpLogItem({
    super.key,
    required this.entry,
    this.selected = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    MaterialColor effectiveStatusColor =
        entry.error != null ? Colors.red : entry.statusColor;
    Duration? duration = entry.duration;
    MaterialColor effectiveDurationColor = entry.durationColor;

    return DataCard(
      selected: selected,
      onTap: onSelected,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: effectiveStatusColor.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 51),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Text(
                        entry.response?.statusCode?.toString() ??
                            (entry.error != null ? "ERROR" : "-"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: effectiveStatusColor.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        entry.method?.toUpperCase() ?? "-",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (duration != null)
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: effectiveDurationColor.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              child: Text(
                                duration.toHumanString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: effectiveDurationColor.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (duration != null) const SizedBox(width: 15),
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: "Copy URL",
                onPressed: () {
                  if (entry.uri != null) {
                    Utils.copyToClipboard(context, value: entry.uri.toString());
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              entry.uri?.toString() ?? "-",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(entry.request?.time?.toString() ?? ""),
              ),
              Expanded(
                child: Text(
                  entry.responseTime?.toString() ?? "",
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
