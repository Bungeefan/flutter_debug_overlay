import 'package:collection/collection.dart';

import '../http_log/http_interaction.dart';
import 'bucket.dart';

/// A bucket that holds [HttpInteraction]'s.
///
/// If [maxStoredEntries] gets exceeded, the first entries are removed.
class HttpBucket extends Bucket<HttpInteraction> {
  HttpBucket({
    super.maxStoredEntries,
    super.allowDuplicates = true,
  });

  /// Returns the corresponding [HttpInteraction] to this [id].
  ///
  /// To modify the [HttpInteraction], use these:
  /// * [addResponse]
  /// * [addError]
  HttpInteraction? getHttpInteraction(int id) {
    return entries.firstWhereOrNull((element) => element.id == id);
  }

  /// Allows to add a [response] to an already added [HttpInteraction],
  /// returns true on success.
  ///
  /// This also notifies the listeners of this bucket.
  bool addResponse(int id, HttpResponse response) {
    var interaction = getHttpInteraction(id);
    if (interaction != null) {
      interaction.response = response;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Allows to add an [error] to an already added [HttpInteraction],
  /// returns true on success.
  ///
  /// This also notifies the listeners of this bucket.
  bool addError(int id, HttpError error) {
    var interaction = getHttpInteraction(id);
    if (interaction != null) {
      interaction.error = error;
      notifyListeners();
      return true;
    }
    return false;
  }
}
