import 'package:flutter/widgets.dart';

import 'filter_mixin.dart';

mixin SearchCapability<T extends StatefulWidget>
    on State<T>, FilterCapability<T> {
  late final TextEditingController searchController;
  String? searchFilter;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  void onSearch(String text) {
    String? oldFilter = searchFilter;
    searchFilter = text.toLowerCase();
    if (oldFilter != searchFilter) {
      updateFilter();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
