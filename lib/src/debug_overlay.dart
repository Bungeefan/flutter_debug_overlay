import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'action_value/action/debug_action.dart';
import 'action_value/action_value_page.dart';
import 'action_value/value/debug_value.dart';
import 'debug/debug_page.dart';
import 'debug_detector.dart';
import 'http_log/http_log_page.dart';
import 'info/entry/device_entry.dart';
import 'info/entry/media_query_entry.dart';
import 'info/entry/package_entry.dart';
import 'info/entry/platform_entry.dart';
import 'info/info_page.dart';
import 'log/log_page.dart';
import 'util/http_bucket.dart';
import 'util/log_bucket.dart';
import 'util/page_tab_switcher.dart';

typedef DetectorBuilder = Widget Function(VoidCallback onDetect, Widget child);

/// A widget that adds a debug overlay to the app, allowing for easy debugging of various components.
///
/// The overlay can display logs in a sorted view and inspect HTTP requests with a JSON viewer.
///
/// To use the [DebugOverlay] widget, simply insert it at any point in your
/// widget tree or use [DebugOverlay.builder] in your [WidgetsApp.builder].
///
/// It is recommended to use your own builder, as this allows a
/// higher usability and customizability.
class DebugOverlay extends StatefulWidget {
  /// Whether overlays should be usable.
  ///
  /// Defaults to the value of [kDebugMode].
  static bool enabled = kDebugMode;

  /// Whether the overlay is initially visible.
  final bool visible;

  /// Whether the overlay should maintain its state while being invisible to the user.
  ///
  /// Allows for a quick resume when toggling the overlay while inspecting something.
  final bool maintainState;

  /// Specifies which tab should be initially shown when activating the overlay.
  final int initialTabIndex;

  /// Allows the debug overlay to be partially transparent.
  final double opacity;

  /// Allows the injection of a custom detector instead of the default [DebugDetector].
  final DetectorBuilder detectorBuilder;

  /// Custom widgets that will be usable from the debug overlay.
  final List<Widget> debugEntries;

  /// Custom information widgets that will be displayed in the "INFO" tab.
  final List<Widget> infoEntries;

  /// Bucket to collect log entries.
  final LogBucket? logBucket;

  /// Bucket to collect HTTP requests.
  final HttpBucket? httpBucket;

  /// The child widget that will be placed in the stack under the overlay.
  ///
  /// Usually this is the Navigator from [WidgetsApp.builder].
  final Widget child;

  /// Specifies a list of fields whose values are hidden throughout the overlay.
  ///
  /// This list is case-insensitive checked.
  ///
  /// Examples:
  /// * [HttpHeaders.authorizationHeader]
  /// * `"token"`
  final List<String> hiddenFields;

  /// Creates a [DebugOverlay] widget.
  ///
  /// [maintainState] controls whether the overlay should maintain its state
  /// while being invisible to the user, this allows for a quick resume
  /// when toggling the overlay while inspecting something.
  ///
  /// [detectorBuilder] allows the injection of a custom detector instead
  /// of the default [DebugDetector].
  ///
  /// [hiddenFields] specifies a list of fields whose values are hidden
  /// throughout the overlay.
  DebugOverlay({
    super.key,
    this.visible = false,
    bool? maintainState,
    this.initialTabIndex = 0,
    this.opacity = 0.9,
    DetectorBuilder? detectorBuilder,
    List<String> hiddenFields = const [],
    this.logBucket,
    this.httpBucket,
    this.debugEntries = const [],
    this.infoEntries = const [
      MediaQueryInfoEntry(),
      PackageInfoEntry(),
      DeviceInfoEntry(),
      if (!kIsWeb) PlatformInfoEntry(),
    ],
    required this.child,
  })  : maintainState = maintainState ?? true,
        detectorBuilder = detectorBuilder ?? _buildDetector,
        hiddenFields = hiddenFields.map((e) => e.toLowerCase()).toList();

  static Widget _buildDetector(VoidCallback onDetect, Widget child) {
    return DebugDetector(
      onDetect: onDetect,
      child: child,
    );
  }

  /// Convenience builder for [WidgetsApp.builder].
  ///
  /// Creates the Debug Overlay and puts in on top of the [Router]/[Navigator].
  ///
  /// [DebugOverlay.enabled] controls whether overlays are enabled and usable.
  ///
  /// [maintainState] controls whether the overlay should maintain its state
  /// while being invisible to the user, this allows for a quick resume
  /// when toggling the overlay while inspecting something.
  ///
  /// [detectorBuilder] allows the injection of a custom detector instead
  /// of the default [DebugDetector].
  ///
  /// [hiddenFields] specifies a list of fields whose values are hidden
  /// throughout the overlay.
  static TransitionBuilder builder({
    bool? maintainState,
    int initialTabIndex = 0,
    double opacity = 0.9,
    DetectorBuilder? detectorBuilder,
    List<String> hiddenFields = const [],
    LogBucket? logBucket,
    HttpBucket? httpBucket,
    List<Widget> debugEntries = const [],
  }) {
    return (context, child) {
      return DebugOverlay(
        maintainState: maintainState,
        initialTabIndex: initialTabIndex,
        opacity: opacity,
        detectorBuilder: detectorBuilder,
        hiddenFields: hiddenFields,
        logBucket: logBucket,
        httpBucket: httpBucket,
        debugEntries: debugEntries,
        child: child ?? const SizedBox.shrink(),
      );
    };
  }

  /// Finds the [DebugOverlayState] from the closest instance of this class that
  /// encloses the given context.
  static DebugOverlayState of(BuildContext context) {
    final DebugOverlayState? result = maybeOf(context);
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts([
      ErrorSummary(
        "DebugOverlay.of() called with a context that does not contain a DebugOverlay.",
      ),
      context.describeElement("The context used was"),
    ]);
  }

  /// Finds the [DebugOverlayState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static DebugOverlayState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<DebugOverlayState>();
  }

  @override
  State<DebugOverlay> createState() => DebugOverlayState();
}

class DebugOverlayState extends State<DebugOverlay> {
  late HeroController _heroController;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  final PageStorageBucket _storageBucket = PageStorageBucket();
  BackButtonDispatcher? _backButtonDispatcher;

  final List<DebugAction> _actions = [];
  final List<DebugValue> _values = [];

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _visible = widget.visible;
    _heroController = MaterialApp.createMaterialHeroController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_backButtonDispatcher == null) {
      BackButtonDispatcher? parentDispatcher =
          Router.maybeOf(context)?.backButtonDispatcher;
      _backButtonDispatcher =
          parentDispatcher?.createChildBackButtonDispatcher() ??
              RootBackButtonDispatcher();
      _backButtonDispatcher!.takePriority();
      _backButtonDispatcher!.addCallback(_dispatchBackButton);
    }
  }

  @override
  void didUpdateWidget(covariant DebugOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _visible = widget.visible;
    }
  }

  @override
  void dispose() {
    _backButtonDispatcher?.removeCallback(_dispatchBackButton);
    super.dispose();
  }

  Future<bool> _dispatchBackButton() async {
    if (_visible) {
      bool? handled = await _navigatorKey.currentState?.maybePop();
      if (!(handled ?? true)) {
        toggleVisibility();
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (DebugOverlay.enabled) {
      return widget.detectorBuilder.call(
        () => toggleVisibility(),
        Stack(
          children: [
            widget.child,
            Visibility(
              visible: _visible,
              maintainState: widget.maintainState,
              child: _buildOverlay(context),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }

  Widget _buildOverlay(BuildContext context) {
    return PageStorage(
      bucket: _storageBucket,
      child: Opacity(
        opacity: widget.opacity,
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
            scaffoldBackgroundColor: Theme.of(context)
                .scaffoldBackgroundColor
                .withValues(alpha: widget.opacity),
          ),
          child: HeroControllerScope(
            controller: _heroController,
            child: ScaffoldMessenger(
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (settings) => MaterialPageRoute(
                  settings: settings,
                  builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text("Debug"),
                        actions: [
                          CloseButton(onPressed: toggleVisibility),
                        ],
                      ),
                      body: PageTabSwitcher(
                        initialIndex: widget.initialTabIndex,
                        physics: !Theme.of(context).useMaterial3
                            ? const BouncingScrollPhysics()
                            : null,
                        items: {
                          if (widget.debugEntries.isNotEmpty)
                            "Debug": DebugPage(entries: widget.debugEntries),
                          if (widget.infoEntries.isNotEmpty)
                            "Info": InfoPage(entries: widget.infoEntries),
                          if (widget.logBucket != null)
                            "Logs": LogPage(bucket: widget.logBucket!),
                          if (widget.httpBucket != null)
                            "HTTP": HttpLogPage(
                              bucket: widget.httpBucket!,
                              hiddenFields: widget.hiddenFields,
                            ),
                          if (_actions.isNotEmpty || _values.isNotEmpty)
                            "Actions/Values": ActionValuePage(
                              actions: _actions,
                              values: _values,
                            ),
                        },
                        placeholderBuilder: (context) => Center(
                          child: Text(
                            "No entries configured",
                            style: Theme.of(context).textTheme.titleLarge!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get isVisible => _visible;

  void toggleVisibility() => setState(() => _visible = !_visible);

  /// Adds a [debugValue] for display [ActionValuePage].
  ///
  /// Don't forget to remove it with [removeValue] in your [State.dispose]!
  void addValue(DebugValue debugValue) {
    _values.add(debugValue);
    _safeSetState();
  }

  /// Removes a [debugValue] from [ActionValuePage] via its [listenable].
  void removeValue(ValueListenable listenable) {
    _values.removeWhere((element) => element.listenable == listenable);
    _safeSetState();
  }

  /// Clears all [DebugValue]s from [ActionValuePage].
  void clearValues() {
    _values.clear();
    _safeSetState();
  }

  /// Adds a [DebugAction] for display [ActionValuePage].
  void addAction(DebugAction debugAction) {
    _actions.add(debugAction);
    _safeSetState();
  }

  /// Removes a [DebugAction] from [ActionValuePage] via its [onAction].
  ///
  /// Don't forget to remove it with [removeAction] in your [State.dispose]!
  void removeAction(VoidCallback onAction) {
    _actions.removeWhere((element) => element.onAction == onAction);
    _safeSetState();
  }

  /// Clears all [DebugAction]s from [ActionValuePage].
  void clearActions() {
    _actions.clear();
    _safeSetState();
  }

  void _safeSetState() {
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }
}
