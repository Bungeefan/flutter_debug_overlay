import 'package:flutter/material.dart';

class EnumerationPoints extends StatelessWidget {
  final Map<String, dynamic> entries;
  final List<String> hiddenFields;
  final void Function(MapEntry<String, dynamic> entry)? onLongPress;

  const EnumerationPoints(
    this.entries, {
    super.key,
    this.hiddenFields = const [],
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var entry in entries.entries)
            InkWell(
              onLongPress: onLongPress != null &&
                      !hiddenFields.any((e) => e == entry.key.toLowerCase())
                  ? () => onLongPress?.call(entry)
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${entry.key}:",
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 5),
                      hiddenFields.any((e) => e == entry.key.toLowerCase())
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 6,
                                ),
                                child: const Text(
                                  "Hidden",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              entry.value.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
