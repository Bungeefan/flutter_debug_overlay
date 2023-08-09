import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../util/log_bucket.dart';
import '../util/split_page.dart';
import 'details/log_details_page.dart';
import 'log_event.dart';
import 'log_item.dart';

class LogPage extends StatefulWidget {
  final LogBucket bucket;

  const LogPage({
    super.key,
    required this.bucket,
  });

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<LogEvent> events = [];
  LogEvent? currentEntry;

  @override
  void initState() {
    super.initState();
    _updateBucket();
    widget.bucket.addListener(_updateBucket);
  }

  @override
  void didUpdateWidget(covariant LogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bucket != oldWidget.bucket) {
      oldWidget.bucket.removeListener(_updateBucket);
      widget.bucket.addListener(_updateBucket);
    }
  }

  @override
  void dispose() {
    widget.bucket.removeListener(_updateBucket);
    super.dispose();
  }

  void _updateBucket() {
    events = widget.bucket.entries.sortedByCompare<DateTime>(
      (event) => event.time,
      (a, b) => b.compareTo(a),
    );
    _safeSetState();
  }

  void _safeSetState() {
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Logs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: widget.bucket.entries.isNotEmpty
                    ? () {
                        currentEntry = null;
                        widget.bucket.clear();
                        _updateBucket();
                      }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outlined),
                label: const Text("Clear logs"),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildPage(context),
        ),
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          "No logs",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    return SplitPage(
      mainBuilder: (context, split) => _buildMain(context, split, events),
      detailBuilder: _buildDetail,
      onSplitChange: (split) {
        if (!split) {
          _openLogDetails(context);
        }
      },
    );
  }

  void _openLogDetails(BuildContext context) {
    if (currentEntry != null) {
      var entry = currentEntry!;
      currentEntry = null;
      showDialog(
        context: context,
        useRootNavigator: false,
        barrierColor: Colors.transparent,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Log Details"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LogDetailsPage(
              entry: entry,
            ),
          ),
        ),
      ).then((value) => setState(() => currentEntry = entry));
    }
  }

  Widget _buildMain(BuildContext context, bool split, Iterable<LogEvent> logs) {
    return ListView.separated(
      key: PageStorageKey(widget.bucket),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return LogItem(
          key: ObjectKey(logs.elementAt(index)),
          entry: logs.elementAt(index),
          onSelected: () {
            currentEntry = logs.elementAt(index);
            if (split) {
              setState(() {});
            } else {
              _openLogDetails(context);
            }
          },
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildDetail(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: currentEntry != null
          ? LogDetailsPage(
              entry: currentEntry!,
            )
          : Center(
              child: Text(
                "No selection",
                style: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
    );
  }
}
