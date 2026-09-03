import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../styles/flow_toast_style.dart';
import '../widgets/flow_toast.dart';

// The toast layer: one OverlayEntry per Overlay, raised by the first toast
// and dropped once the last one has left. Only showFlowToast and
// FlowToastHandle are exported from the package barrel.

/// The frost under every toast: the design's 3px blur of the page. One
/// filter for all of them — a [BackdropFilter] repaints the whole viewport
/// whenever its filter changes, the preview's note.
final ImageFilter _blurFilter = ImageFilter.blur(sigmaX: 3, sigmaY: 3);

/// Floats a [FlowToast] in the nearest [Overlay] and hands back its handle.
///
/// ```dart
/// showFlowToast(
///   context: context,
///   icon: Icons.copy_outlined,
///   message: 'Message copied to clipboard',
///   dismissTooltip: 'Dismiss',
/// )
/// ```
///
/// No setup: the layer raises itself in the overlay above [context] — a
/// `MaterialApp`, a `Navigator`, or an `Overlay` of the host's own, the
/// nearest one, so an `Overlay.wrap` around a pane keeps its toasts inside
/// it; [rootOverlay] reaches the app's instead, as `Overlay.of` does — and
/// leaves again once the last toast has gone. Toasts sit above every
/// route, dialogs and sheets included.
///
/// Where it floats is read from the overlay's own width: 358 wide, 24 in
/// from the top end corner, on layouts 600 and wider; the full width inside
/// 16 from the top edge below that. Both distances measure from the
/// display's edge and absorb its own insets — a notch pushes the card only
/// as far as it exceeds them.
/// Newer toasts stack above older ones, 8 apart, three at most; a fourth
/// dismisses the oldest.
///
/// A toast leaves on its own after [duration] — four seconds unless told
/// otherwise, the clock paused while the pointer is over it — or at once
/// from its cross or [FlowToastHandle.dismiss]. Null keeps it up until
/// dismissed, for a notice that tracks work in progress. Under assistive
/// navigation no toast leaves on its own, the snack bar's rule: a notice
/// gone before it was reached was never shown.
///
/// Call it from a handler, not from a build: raising the layer rebuilds
/// the overlay, which a build in progress forbids — the same rule as
/// pushing a route.
FlowToastHandle showFlowToast({
  required BuildContext context,
  required String message,
  IconData? icon,
  Duration? duration = const Duration(seconds: 4),
  String? dismissTooltip,
  bool rootOverlay = false,
  FlowToastStyle? style,
}) {
  assert(
    duration == null || duration > Duration.zero,
    'duration must be positive, or null for a toast that stays until '
    'dismissed',
  );
  final toast = FlowToast(
    message: message,
    icon: icon,
    dismissTooltip: dismissTooltip,
    style: style,
  );
  // The framework's own error names the widget: "No Overlay widget found.
  // FlowToast widgets require an Overlay widget ancestor…".
  final overlay = Overlay.of(
    context,
    rootOverlay: rootOverlay,
    debugRequiredFor: toast,
  );
  return _FlowToastStack.of(overlay).show(toast, duration: duration);
}

/// A toast [showFlowToast] floated: dismiss it early, or wait for it to go.
class FlowToastHandle {
  FlowToastHandle._(this._record);

  final _FlowToastRecord _record;

  /// Starts the exit. A no-op once the toast has left.
  void dismiss() => _record.dismiss();

  /// Completes once the toast has left the tree — dismissed, timed out,
  /// pushed off by newer ones, or its overlay torn down.
  Future<void> get closed => _record.closed.future;

  /// True until [closed] completes, the exit animation included.
  bool get isShowing => !_record.closed.isCompleted;
}

/// One floated toast: what to draw, how long it stays, and where it is in
/// its life.
class _FlowToastRecord {
  _FlowToastRecord(this.toast, {required this.duration});

  final FlowToast toast;
  final Duration? duration;
  final Completer<void> closed = Completer<void>();

  /// Installed by the item once it is on screen; the handle's dismiss
  /// lands here. A dismiss before that is remembered and honoured on
  /// mount.
  VoidCallback? leave;
  bool dismissed = false;

  void dismiss() {
    if (dismissed || closed.isCompleted) return;
    dismissed = true;
    leave?.call();
  }

  void close() {
    if (!closed.isCompleted) closed.complete();
  }
}

/// The toasts over one [Overlay], and the entry that draws them.
class _FlowToastStack extends ChangeNotifier {
  _FlowToastStack._(this.overlay);

  /// Three at most; a fourth pushes the oldest off.
  static const int _maxVisible = 3;

  /// Live stacks by overlay. Statics survive a hot reload and so do the
  /// [OverlayState]s keying them, so the map stays valid across one; a hot
  /// restart starts both over.
  static final Map<OverlayState, _FlowToastStack> _stacks = {};

  static _FlowToastStack of(OverlayState overlay) =>
      _stacks.putIfAbsent(overlay, () => _FlowToastStack._(overlay).._mount());

  final OverlayState overlay;

  /// Newest first — the order they stack in, nearest the edge.
  final List<_FlowToastRecord> toasts = [];

  late final OverlayEntry _entry = OverlayEntry(
    builder: (_) => _FlowToastLayer(stack: this),
  );
  bool _released = false;

  void _mount() => overlay.insert(_entry);

  FlowToastHandle show(FlowToast toast, {required Duration? duration}) {
    final record = _FlowToastRecord(toast, duration: duration);
    toasts.insert(0, record);
    for (final old in toasts.skip(_maxVisible)) {
      old.dismiss();
    }
    notifyListeners();
    return FlowToastHandle._(record);
  }

  /// From an item, once its exit has run.
  void remove(_FlowToastRecord record) {
    if (!toasts.remove(record)) return;
    record.close();
    if (toasts.isNotEmpty) {
      notifyListeners();
      return;
    }
    // The last one left: the entry goes now, and the layer's dispose —
    // next frame, once the overlay has rebuilt without it — drops the
    // notifier. remove() then dispose() back to back is the SDK's own
    // idiom.
    _release();
    _entry
      ..remove()
      ..dispose();
  }

  void _release() {
    _released = true;
    _stacks.remove(overlay);
  }

  /// The layer unmounted. After a release that is the tail of the normal
  /// path. Otherwise the overlay is going away under live toasts — its
  /// route popped, the playground remounting its phone, a hot restart —
  /// and this runs inside its unmount cascade, while `overlay.mounted`
  /// still reads true: the entry is let go a microtask later, when
  /// remove() on a dead overlay is the documented no-op.
  void layerUnmounted() {
    if (_released) {
      dispose();
      return;
    }
    _release();
    for (final record in toasts) {
      record.close();
    }
    toasts.clear();
    scheduleMicrotask(() {
      _entry
        ..remove()
        ..dispose();
      dispose();
    });
  }
}

/// The entry's widget: the stack's toasts in a column at the overlay's
/// top edge, placed by the overlay's own width.
class _FlowToastLayer extends StatefulWidget {
  const _FlowToastLayer({required this.stack});

  final _FlowToastStack stack;

  @override
  State<_FlowToastLayer> createState() => _FlowToastLayerState();
}

class _FlowToastLayerState extends State<_FlowToastLayer> {
  /// Compact begins below 600 — the chat view's boundary, read from the
  /// overlay's own constraints so a pane or a phone frame counts. Compact
  /// spans the width inside 16 from the top edge; wide sits 358 across,
  /// 24 in from the top end corner. Toasts stack 8 apart, newest nearest
  /// the edge.
  static const double _compactBreakpoint = 600;
  static const double _compactInset = 16;
  static const double _wideInset = 24;
  static const double _wideWidth = 358;
  static const double _gap = 8;

  @override
  void dispose() {
    widget.stack.layerUnmounted();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read above the SafeArea below, which consumes this padding: inside
    // it the value always reads zero. The design's distances measure from
    // the display's edge, so they absorb its insets rather than stacking
    // on them — a notch would otherwise stand the card 24 below a 47pt
    // status bar, a gap the design never drew. Simulated phone frames
    // report no inset and keep the full distance. The chat view's rule.
    final safe = MediaQuery.paddingOf(context);

    // No Scaffold up here — the overlay sits above every route — and text
    // with no Material ancestor takes the framework's fallback style, the
    // preview's note.
    return Material(
      type: MaterialType.transparency,
      // The layer owns the display's top edge, so it clears the insets
      // itself. Every wrapper below is a proxy box with no hit test of
      // its own, so a tap beside a toast reaches the page.
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < _compactBreakpoint;
            final inset = compact ? _compactInset : _wideInset;
            return Align(
              alignment: compact
                  ? Alignment.topCenter
                  : AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  math.max(0, inset - safe.left),
                  math.max(0, inset - safe.top),
                  math.max(0, inset - safe.right),
                  math.max(0, inset - safe.bottom),
                ),
                child: SizedBox(
                  width: compact ? double.infinity : _wideWidth,
                  child: ListenableBuilder(
                    listenable: widget.stack,
                    builder: (context, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, record)
                            in widget.stack.toasts.indexed) ...[
                          if (i > 0) const SizedBox(height: _gap),
                          _FlowToastItem(
                            key: ObjectKey(record),
                            stack: widget.stack,
                            record: record,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One toast in the layer: its entrance and exit, its clock, and the frost
/// beneath it.
class _FlowToastItem extends StatefulWidget {
  const _FlowToastItem({super.key, required this.stack, required this.record});

  final _FlowToastStack stack;
  final _FlowToastRecord record;

  @override
  State<_FlowToastItem> createState() => _FlowToastItemState();
}

class _FlowToastItemState extends State<_FlowToastItem>
    with SingleTickerProviderStateMixin {
  /// Enter: fade in and settle 8 down from the edge over the drop
  /// treatment's 150ms; exit: the fade alone, run back.
  static const Duration _reveal = Duration(milliseconds: 150);
  static const double _settle = 8;

  /// The frost's corner — the card's 12, kept in step by hand.
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _reveal,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  bool _started = false;
  bool _leaving = false;
  Timer? _timer;
  Duration? _remaining;
  final Stopwatch _elapsed = Stopwatch();

  @override
  void initState() {
    super.initState();
    _remaining = widget.record.duration;
    widget.record.leave = _leave;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion collapses both legs to nothing. MediaQuery is a
    // dependency, so it is read here: on the first pass to start, after
    // that to follow a change.
    _controller.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _reveal;
    if (_started) return;
    _started = true;
    if (widget.record.dismissed) {
      // Dismissed before it was drawn: no entrance, straight out.
      _leaving = true;
      _exit();
      return;
    }
    _controller.forward();
    _arm();
  }

  @override
  void dispose() {
    // The record outlives this state in the handle; a late dismiss must
    // not land on it.
    widget.record.leave = null;
    _timer?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Armed on show, paused under the pointer, resumed with what was left.
  /// Never for a sticky toast, nor under assistive navigation, where a
  /// notice that leaves on its own may leave before it was reached — the
  /// snack bar's rule.
  void _arm() {
    final left = _remaining;
    if (left == null || _leaving || _timer != null) return;
    if (MediaQuery.accessibleNavigationOf(context)) return;
    _elapsed
      ..reset()
      ..start();
    _timer = Timer(left, () {
      _timer = null;
      _leave();
    });
  }

  void _pause() {
    final timer = _timer;
    if (timer == null) return;
    timer.cancel();
    _timer = null;
    _elapsed.stop();
    final left = _remaining! - _elapsed.elapsed;
    _remaining = left.isNegative ? Duration.zero : left;
  }

  void _leave() {
    if (_leaving) return;
    _timer?.cancel();
    _timer = null;
    setState(() => _leaving = true);
    _exit();
  }

  void _exit() {
    // whenCompleteOrCancel, not await: a controller disposed mid-exit —
    // the overlay torn down under a leaving toast — never resolves the
    // plain future, and the stack has already closed the record.
    _controller.reverse().whenCompleteOrCancel(() {
      if (!mounted) return;
      widget.stack.remove(widget.record);
    });
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.record.toast;
    final card = FlowToast(
      message: source.message,
      icon: source.icon,
      dismissTooltip: source.dismissTooltip,
      style: source.style,
      onDismiss: _leave,
    );

    return IgnorePointer(
      ignoring: _leaving,
      child: ExcludeSemantics(
        excluding: _leaving,
        child: MouseRegion(
          onEnter: (_) => _pause(),
          onExit: (_) => _arm(),
          child: AnimatedBuilder(
            animation: _curve,
            child: card,
            builder: (context, child) {
              final t = _curve.value;
              // A canvas transform, not an offscreen layer, so the frost
              // below still samples the page through it.
              return Transform.translate(
                offset: Offset(0, -_settle * (1 - t)),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    // The frost is a sibling *behind* the card, never an
                    // ancestor of its fade: anything inside an Opacity
                    // joins that layer, and a BackdropFilter in there
                    // samples the layer, not the page — the preview's
                    // rule. Opacity skips its layer at 1, so a settled
                    // toast costs one filter and nothing else.
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: _radius,
                        child: BackdropFilter(
                          filter: _blurFilter,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Opacity(opacity: t, child: child),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
