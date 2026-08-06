import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/flow_theme.dart';

/// Animated reveal for text that arrives incrementally.
///
/// Streaming is data, not streams: rebuild this widget with a progressively
/// longer [text] while [isStreaming] is true and the delta is revealed with a
/// smooth per-character fade. When [isStreaming] is false the text renders
/// statically with no animation cost, so the same widget is safe for history
/// messages.
///
/// The reveal runs at [charactersPerSecond] but speeds up automatically
/// whenever it would fall more than a beat behind the incoming text, so fast
/// streams never leave the animation lagging. If a new [text] does not extend
/// the previous one (a regenerate or branch switch), the reveal restarts.
class FlowStreamingText extends StatefulWidget {
  const FlowStreamingText({
    super.key,
    required this.text,
    this.isStreaming = true,
    this.style,
    this.charactersPerSecond = 300,
    this.textAlign,
  }) : assert(charactersPerSecond > 0, 'charactersPerSecond must be positive');

  /// The full text received so far.
  final String text;

  /// Whether more text may still arrive. While true the reveal animates;
  /// when it flips to false the remainder fast-forwards in. Defaults to
  /// true — pass false for settled history messages to skip all animation.
  final bool isStreaming;

  /// Merged over the default `bodyLarge` + `onSurface` style.
  final TextStyle? style;

  /// Baseline reveal speed. The widget adapts above this to keep up with
  /// fast streams.
  final double charactersPerSecond;

  final TextAlign? textAlign;

  @override
  State<FlowStreamingText> createState() => _FlowStreamingTextState();
}

class _FlowStreamingTextState extends State<FlowStreamingText>
    with SingleTickerProviderStateMixin {
  /// How long a revealed character takes to fade to full opacity.
  static const double _fadeSeconds = 0.25;

  /// Maximum time the reveal may lag behind the incoming text.
  static const double _maxLagSeconds = 0.4;

  /// Catch-up window once streaming has completed.
  static const double _fastForwardSeconds = 0.15;

  /// Upper bound on individually faded spans per frame.
  static const int _maxFadeSpans = 60;

  late final Ticker _ticker;

  /// Characters revealed so far (fractional between characters).
  double _revealed = 0;

  /// Monotonic clock in seconds, accumulated across ticker runs.
  double _clock = 0;

  /// Reveal timestamps: entry `i` is for character `_stampBase + i`.
  /// Characters below [_stampBase] were revealed without animation.
  final List<double> _revealedAt = <double>[];
  int _stampBase = 0;

  Duration _lastElapsed = Duration.zero;
  bool _fastForwarding = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.isStreaming) {
      _ensureTicking();
    } else {
      _revealed = widget.text.length.toDouble();
      _stampBase = widget.text.length;
    }
  }

  @override
  void didUpdateWidget(FlowStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final extended =
        widget.text.length >= oldWidget.text.length &&
        widget.text.startsWith(oldWidget.text);
    if (!extended) {
      // Replacement: regenerate / branch switch.
      _revealedAt.clear();
      _fastForwarding = false;
      if (widget.isStreaming) {
        _revealed = 0;
        _stampBase = 0;
        _ensureTicking();
      } else {
        _snapToEnd();
      }
      return;
    }

    if (widget.isStreaming) {
      _fastForwarding = false;
      if (_revealed < widget.text.length) _ensureTicking();
    } else if (oldWidget.isStreaming) {
      // Stream completed: fast-forward whatever is left.
      if (_revealed < widget.text.length || _tailStillFading) {
        _fastForwarding = true;
        _ensureTicking();
      }
    } else if (widget.text != oldWidget.text) {
      // Static text changed outside of streaming: no animation.
      _snapToEnd();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool get _tailStillFading =>
      _revealedAt.isNotEmpty && _clock - _revealedAt.last < _fadeSeconds;

  void _ensureTicking() {
    if (_ticker.isActive) return;
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void _snapToEnd() {
    _ticker.stop();
    _revealed = widget.text.length.toDouble();
    _revealedAt.clear();
    _stampBase = widget.text.length;
    _fastForwarding = false;
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0) return;
    _clock += dt;

    final target = widget.text.length.toDouble();
    var speed = widget.charactersPerSecond;
    final backlog = target - _revealed;
    if (backlog > 0) {
      // Adapt so the backlog clears within the lag window.
      final window = _fastForwarding ? _fastForwardSeconds : _maxLagSeconds;
      speed = math.max(speed, backlog / window);
    }

    setState(() {
      final before = _revealed.floor();
      _revealed = math.min(_revealed + speed * dt, target);
      final count = _revealed.floor() - before;
      // Stamp newly revealed characters, spread across this frame's time.
      for (var i = 0; i < count; i++) {
        _revealedAt.add(_clock - dt + dt * (i + 1) / count);
      }
      if (_revealed >= target && !_tailStillFading) {
        _ticker.stop();
        _fastForwarding = false;
      }
    });
  }

  /// Fade-in progress (0–1) for the character at index [index].
  double _fadeProgress(int index) {
    if (index < _stampBase) return 1;
    final i = index - _stampBase;
    if (i >= _revealedAt.length) return 0;
    return ((_clock - _revealedAt[i]) / _fadeSeconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static bool _isHighSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xD800;
  static bool _isLowSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xDC00;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final style = context.flowTypography.bodyLarge
        .copyWith(color: colors.onSurface)
        .merge(widget.style);

    // Settled: history messages and completed streams render statically.
    if (!_ticker.isActive && _revealed >= widget.text.length) {
      return Text(widget.text, style: style, textAlign: widget.textAlign);
    }

    final text = widget.text;
    var shown = math.min(_revealed.floor(), text.length);
    // Never split a surrogate pair at the reveal head.
    if (shown > 0 &&
        shown < text.length &&
        _isLowSurrogate(text.codeUnitAt(shown))) {
      shown--;
    }

    var fadeStart = shown;
    while (fadeStart > 0 &&
        shown - fadeStart < _maxFadeSpans &&
        _fadeProgress(fadeStart - 1) < 1) {
      fadeStart--;
    }
    if (fadeStart > 0 && _isLowSurrogate(text.codeUnitAt(fadeStart))) {
      fadeStart--;
    }

    final baseColor = style.color ?? colors.onSurface;
    final spans = <InlineSpan>[
      if (fadeStart > 0) TextSpan(text: text.substring(0, fadeStart)),
    ];
    var i = fadeStart;
    while (i < shown) {
      final end = _isHighSurrogate(text.codeUnitAt(i)) && i + 1 < shown
          ? i + 2
          : i + 1;
      spans.add(
        TextSpan(
          text: text.substring(i, end),
          style: TextStyle(
            color: baseColor.withValues(alpha: baseColor.a * _fadeProgress(i)),
          ),
        ),
      );
      i = end;
    }

    // Expose the full text once so screen readers aren't re-announced
    // on every animation frame.
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(style: style, children: spans),
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}
