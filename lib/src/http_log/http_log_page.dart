import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../util/filter_mixin.dart';
import '../util/http_bucket.dart';
import '../util/search_field.dart';
import '../util/search_mixin.dart';
import '../util/split_page.dart';
import 'details/http_log_details_page.dart';
import 'http_interaction.dart';
import 'http_log_item.dart';

class HttpLogPage extends StatefulWidget {
  final HttpBucket bucket;
  final List<String> hiddenFields;

  const HttpLogPage({
    super.key,
    required this.bucket,
    this.hiddenFields = const [],
  });

  @override
  State<HttpLogPage> createState() => _HttpLogPageState();
}

class _HttpLogPageState extends State<HttpLogPage>
    with AutomaticKeepAliveClientMixin, FilterCapability, SearchCapability {
  List<HttpInteraction> interactions = [];
  HttpInteraction? currentEntry;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _updateBucket();
    widget.bucket.addListener(_updateBucket);
  }

  @override
  void didUpdateWidget(covariant HttpLogPage oldWidget) {
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
    Iterable<HttpInteraction> stream = widget.bucket.entries;
    if (filterEnabled) {
      if (searchFilter?.isNotEmpty ?? false) {
        List<String> searchQueries = searchFilter!.split(RegExp("\\s"));
        stream = stream.where((e) {
          for (String query in searchQueries) {
            bool match = [
              e.uri,
              e.method,
              e.request?.time,
              e.response?.statusCode,
              e.response?.time,
              e.error?.time,
              e.error?.error,
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
    interactions = stream.sortedByCompare<DateTime?>(
      (event) => event.request?.time ?? event.responseTime,
      (a, b) => a != null && b != null ? b.compareTo(a) : -1,
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
            mainBuilder: (context, split) =>
                _buildMain(context, split, interactions),
            detailBuilder: _buildDetail,
            onSplitChange: (split) {
              if (!split) {
                _openHttpLogDetails(context);
              }
            },
          ),
        ),
      ],
    );
  }

  void _openHttpLogDetails(BuildContext context) {
    if (currentEntry != null) {
      var entry = currentEntry!;
      currentEntry = null;
      showDialog(
        context: context,
        useRootNavigator: false,
        barrierColor: Colors.transparent,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("HTTP Details"),
          ),
          body: HttpLogDetailsPage(
            entry: entry,
            hiddenFields: widget.hiddenFields,
          ),
        ),
      ).then((value) => setState(() => currentEntry = entry));
    }
  }

  Widget _buildMain(
    BuildContext context,
    bool split,
    Iterable<HttpInteraction> interactions,
  ) {
    return Column(
      children: [
        if (filterEnabled) _buildFilter(context),
        Expanded(
          child: _buildInteractionsList(split, interactions),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Requests",
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
              iconColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.delete_outlined),
            label: const Text("Clear requests"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: SearchField(
              controller: searchController,
              onSearch: onSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionsList(
    bool split,
    Iterable<HttpInteraction> interactions,
  ) {
    if (interactions.isEmpty) {
      return Center(
        child: Text(
          "No requests",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey(widget.bucket),
      itemCount: interactions.length,
      itemBuilder: (context, index) {
        var httpInteraction = interactions.elementAt(index);
        return HttpLogItem(
          key: ObjectKey(httpInteraction),
          entry: httpInteraction,
          selected: split && currentEntry != null
              ? currentEntry == httpInteraction
              : false,
          onSelected: () {
            currentEntry = httpInteraction;
            if (split) {
              setState(() {});
            } else {
              _openHttpLogDetails(context);
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: currentEntry != null
          ? HttpLogDetailsPage(
              entry: currentEntry!,
              hiddenFields: widget.hiddenFields,
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
