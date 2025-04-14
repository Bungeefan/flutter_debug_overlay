import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../util/filter_mixin.dart';
import '../util/log_bucket.dart';
import '../util/search_field.dart';
import '../util/search_mixin.dart';
import '../util/split_page.dart';
import 'details/log_details_page.dart';
import 'level_selector.dart';
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

class _LogPageState extends State<LogPage>
    with AutomaticKeepAliveClientMixin, FilterCapability, SearchCapability {
  List<LogEvent> events = [];
  LogEvent? currentEntry;

  LogLevel levelFilter = LogLevel.all;

  @override
  bool get wantKeepAlive => true;

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

  @override
  void updateFilter() {
    _updateBucket();
  }

  void _updateBucket() {
    Iterable<LogEvent> stream = widget.bucket.entries;
    if (filterEnabled) {
      if (levelFilter != LogLevel.all) {
        stream = stream.where((e) => e.level.value >= levelFilter.value);
      }
      if (searchFilter?.isNotEmpty ?? false) {
        List<String> searchQueries = searchFilter!.split(RegExp("\\s"));
        stream = stream.where((e) {
          for (String query in searchQueries) {
            bool match = [
              e.message,
              e.error,
              e.time,
            ].any((element) =>
                element?.toString().toLowerCase().contains(query) ?? false);
            if (!match) {
              return false;
            }
          }
          return true;
        });
      }
    }
    events = stream.sortedByCompare<DateTime>(
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
    super.build(context);

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SplitPage(
            mainBuilder: (context, split) => _buildMain(context, split, events),
            detailBuilder: _buildDetail,
            onSplitChange: (split) {
              if (!split) {
                _openLogDetails(context);
              }
            },
          ),
        ),
      ],
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
    return Column(
      children: [
        if (filterEnabled) _buildFilter(context),
        Expanded(
          child: _buildLogsList(split, logs),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Text(
            "Logs",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              splashRadius: 25,
              tooltip: "Toggle Filter",
              icon: Icon(
                filterEnabled ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              onPressed: toggleFilter,
            ),
          ),
          const Spacer(),
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
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SearchField(
              controller: searchController,
              onSearch: onSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LevelSelector(
              level: levelFilter,
              onLevelChanged: (level) {
                if (level != levelFilter) {
                  levelFilter = level;
                  updateFilter();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(bool split, Iterable<LogEvent> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Text(
          "No logs",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey(widget.bucket),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        var logEvent = logs.elementAt(index);
        return LogItem(
          key: ObjectKey(logEvent),
          entry: logEvent,
          selected:
              split && currentEntry != null ? currentEntry == logEvent : false,
          onSelected: () {
            currentEntry = logEvent;
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
