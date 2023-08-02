import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../util/http_bucket.dart';
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
    with AutomaticKeepAliveClientMixin {
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

  void _updateBucket() {
    interactions = widget.bucket.entries.sortedByCompare<DateTime?>(
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
        Padding(
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
                label: const Text("Clear requests"),
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
    if (interactions.isEmpty) {
      return Center(
        child: Text(
          "No requests",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    return SplitPage(
      mainBuilder: (context, split) => _buildMain(context, split, interactions),
      detailBuilder: _buildDetail,
      onSplitChange: (split) {
        if (!split) {
          _openHttpLogDetails(context);
        }
      },
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

  Widget _buildMain(BuildContext context, bool split,
      Iterable<HttpInteraction> interactions) {
    return ListView.separated(
      key: PageStorageKey(widget.bucket),
      itemCount: interactions.length,
      itemBuilder: (context, index) {
        return HttpLogItem(
          key: ObjectKey(interactions.elementAt(index)),
          entry: interactions.elementAt(index),
          onSelected: () {
            currentEntry = interactions.elementAt(index);
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
