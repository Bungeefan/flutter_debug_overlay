import '../log/log_event.dart';
import 'bucket.dart';

/// A bucket that holds [LogEvent]'s.
///
/// If [maxStoredEntries] gets exceeded, the first logs are removed.
class LogBucket extends Bucket<LogEvent> {
  LogBucket({
    super.maxStoredEntries,
    super.allowDuplicates,
  });
}
