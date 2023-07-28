import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json/flutter_json.dart';

import '../../util/expandable_card.dart';
import '../http_interaction.dart';
import '../item/body_item.dart';

class ErrorPage extends StatefulWidget {
  final List<Widget> children;
  final List<String> hiddenFields;

  const ErrorPage({
    super.key,
    required this.httpInteraction,
    this.hiddenFields = const [],
    required this.children,
  });

  final HttpInteraction httpInteraction;

  @override
  State<ErrorPage> createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage>
    with AutomaticKeepAliveClientMixin {
  late final JsonController _bodyController;
  late final JsonController _dataController;

  bool isEncodable = false;

  // Saves the open/closed states and scroll position.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _bodyController = JsonController();
    _dataController = JsonController();
    _checkError();
  }

  @override
  void didUpdateWidget(covariant ErrorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.httpInteraction.error?.error !=
        oldWidget.httpInteraction.error?.error) {
      _checkError();
    }
  }

  void _checkError() {
    isEncodable = false;
    try {
      jsonEncode(widget.httpInteraction.error!.error);
      isEncodable = true;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.separated(
      physics: !Theme.of(context).useMaterial3
          ? const BouncingScrollPhysics()
          : null,
      itemCount: widget.children.length +
          2 +
          (widget.httpInteraction.error?.additionalData != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.children.length) {
          return widget.children[index];
        }
        switch (index - widget.children.length) {
          case 0:
            if (widget.httpInteraction.error != null) {
              if (isEncodable) {
                return BodyItem(
                  title: const Text("Error"),
                  controller: _bodyController,
                  initialExpandDepth: 4,
                  body: widget.httpInteraction.error?.error,
                  hiddenKeys: widget.hiddenFields,
                );
              } else {
                return ExpandableCard(
                  title: const Text("Error"),
                  expanded: true,
                  child: SelectableText(
                      widget.httpInteraction.error!.error!.toString()),
                );
              }
            }
            return const ExpandableCard(
              title: Text("Error"),
              expanded: true,
              child: Text("No Error"),
            );
          case 1:
            return ExpandableCard(
              title: const Text("Stack Trace"),
              child: widget.httpInteraction.error?.stackTrace
                          ?.toString()
                          .isNotEmpty ??
                      false
                  ? SelectableText(
                      widget.httpInteraction.error!.stackTrace.toString())
                  : null,
            );
          case 2:
            return BodyItem(
              title: const Text("Additional Data"),
              expanded: false,
              controller: _dataController,
              body: widget.httpInteraction.error?.additionalData,
              hiddenKeys: widget.hiddenFields,
            );
          default:
            return const Center(
              child: Text("Empty"),
            );
        }
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _dataController.dispose();
    super.dispose();
  }
}
