import 'package:flutter/material.dart';
import 'package:flutter_json/flutter_json.dart';

import '../http_interaction.dart';
import '../item/body_item.dart';
import '../item/header_item.dart';
import '../item/parameter_item.dart';

class RequestPage extends StatefulWidget {
  final List<Widget> children;
  final List<String> hiddenFields;

  const RequestPage({
    super.key,
    required this.httpInteraction,
    this.hiddenFields = const [],
    required this.children,
  });

  final HttpInteraction httpInteraction;

  @override
  State<RequestPage> createState() => RequestPageState();
}

class RequestPageState extends State<RequestPage>
    with AutomaticKeepAliveClientMixin {
  late final JsonController _bodyController;
  late final JsonController _dataController;

  // Saves the open/closed states and scroll position. (Parent doesn't keep this state)
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _bodyController = JsonController();
    _dataController = JsonController();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.separated(
      physics: !Theme.of(context).useMaterial3
          ? const BouncingScrollPhysics()
          : null,
      itemCount: widget.children.length +
          3 +
          (widget.httpInteraction.request?.additionalData != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.children.length) {
          return widget.children[index];
        }
        switch (index - widget.children.length) {
          case 0:
            return HeaderItem(
              widget.httpInteraction.request?.headers,
              hiddenFields: widget.hiddenFields,
            );
          case 1:
            return ParameterItem(
              widget.httpInteraction.request?.parameters,
              hiddenFields: widget.hiddenFields,
            );
          case 2:
            return BodyItem(
              controller: _bodyController,
              body: widget.httpInteraction.request?.body,
              hiddenKeys: widget.hiddenFields,
            );
          case 3:
            return BodyItem(
              title: const Text("Additional Data"),
              expanded: false,
              controller: _dataController,
              body: widget.httpInteraction.request?.additionalData,
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
