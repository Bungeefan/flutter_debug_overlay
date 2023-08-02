import 'package:flutter/widgets.dart';

mixin FilterCapability<T extends StatefulWidget> on State<T> {
  bool filterEnabled = false;

  void toggleFilter() {
    setState(() => filterEnabled = !filterEnabled);
    updateFilter();
  }

  void updateFilter();
}
