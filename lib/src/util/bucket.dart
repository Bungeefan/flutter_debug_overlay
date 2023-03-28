import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../debug_overlay.dart';

/// Holds data of type [T].
///
/// If [maxStorage] gets exceeded, the first entries are removed.
/// if [maxStorage] is -1, no entries are discarded.
class Bucket<T> extends ChangeNotifier {
  Bucket({
    int? maxStoredEntries = 100,
    this.allowDuplicates = false,
  }) : _maxStoredEntries = maxStoredEntries;

  final Queue<T> _entries = Queue<T>();
  int? _maxStoredEntries;

  Queue<T> get entries => _entries;

  /// The maximum number of stored entries.
  /// Use `null` for unlimited entries.
  int? get maxStorage => _maxStoredEntries;

  /// Updates the max stored entries, trims the bucket if needed.
  set maxStorage(int? value) {
    _maxStoredEntries = maxStorage;

    if (value != null) {
      bool modified = _trimBucket();
      if (modified) {
        notifyListeners();
      }
    }
  }

  bool allowDuplicates;

  /// Adds an entry to the bucket.
  ///
  /// If [maxStorage] gets exceeded, the first added entries are removed.
  ///
  /// This method respects [DebugOverlay.enabled].
  void add(T entry) {
    if (!DebugOverlay.enabled) return;

    if (allowDuplicates || _entries.none((e) => e == entry)) {
      _entries.add(entry);
      _trimBucket();
      notifyListeners();
    }
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  bool _trimBucket() {
    if (_maxStoredEntries == null) return false;

    bool modified = false;
    while (_entries.length > _maxStoredEntries!) {
      _entries.removeFirst();
      modified = true;
    }
    return modified;
  }
}
