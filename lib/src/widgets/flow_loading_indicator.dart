import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';

/// The staggered three-dot pulse shown while the assistant has not started
/// responding yet.
///
/// Bare dots only — message/bubble components provide any background. Once
/// the first token arrives, hosts typically swap this for a
/// `FlowStreamingText`.
///
/// Respects the platform reduced-motion setting by rendering static dots.
class FlowLoadingIndicator extends StatefulWidget {
  const FlowLoadingIndicator({
    super.key,
    this.color,
    this.dotSize = 8,
    this.duration = const Duration(milliseconds: 1200),
    this.semanticLabel,
  }) : assert(dotSize > 0, 'dotSize must be positive');

  /// Dot color. Defaults to `onSurfaceVariant`.
  final Color? color;

  /// Diameter of each dot.
  final double dotSize;

  /// One full pulse cycle across the three dots.
  final Duration duration;

  /// Optional accessibility label (e.g. a localized "Loading").
  /// When null the indicator is purely visual; the package ships no
  /// hardcoded strings.
  final String? semanticLabel;

  @override
  State<FlowLoadingIndicator> createState() => _FlowLoadingIndicatorState();
}

class _FlowLoadingIndicatorState extends State<FlowLoadingIndicator>
    with SingleTickerProviderStateMixin {
  static const double _minOpacity = 0.35;
  static const double _minScale = 0.85;

  late final AnimationController _controller;

  /// Null until first resolved, so the initial [didChangeDependencies]
  /// always syncs (starting the animation).
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only resync when reduced-motion actually changes — this fires for any
    // inherited update (e.g. theme toggles), and an unconditional repeat()
    // would restart the cycle from 0 and hitch the pulse.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(FlowLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (_reduceMotion ?? false) {
      _controller.stop();
    } else {
      // (Re)start so a changed duration takes effect immediately.
      _controller.repeat();
    }
  }

  /// Pulse intensity (0–1) for the dot at [index] given cycle progress [t].
  double _intensity(int index, double t) {
    final phase = (t - index / 3) % 1;
    return math.sin(math.pi * phase).abs();
  }

  Widget _dot(Color color, double intensity) {
    final opacity = _minOpacity + (1 - _minOpacity) * intensity;
    final scale = _minScale + (1 - _minScale) * intensity;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.dotSize,
        height: widget.dotSize,
        decoration: BoxDecoration(
          color: color.withValues(alpha: color.a * opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _row(Color color, double gap, double? t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(width: gap),
          _dot(color, t == null ? 1 : _intensity(i, t)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.flowColors.onSurfaceVariant;
    final gap = context.flowSpacing.xs;

    final visual = RepaintBoundary(
      child: (_reduceMotion ?? false)
          ? _row(color, gap, null)
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _row(color, gap, _controller.value),
            ),
    );

    final label = widget.semanticLabel;
    if (label == null) return visual;
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: visual),
    );
  }
}
