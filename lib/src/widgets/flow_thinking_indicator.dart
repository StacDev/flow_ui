import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/flow_theme.dart';
import 'flow_shimmer_text.dart';

/// The thinking line shown while the assistant has not started responding:
/// a slowly turning, breathing asterisk beside a shimmering, host-supplied
/// label.
///
/// ```dart
/// FlowThinkingIndicator(label: 'Thinking…')
/// ```
///
/// [label] is the whole text — the package ships no strings — and null
/// renders the glyph alone. [active] is the state switch: true animates the
/// asterisk — one slow revolution per cycle, swelling and settling as it
/// turns — and sweeps a [FlowShimmerText] highlight through the label;
/// false holds the same line still in the muted ink, for a host that keeps
/// it on screen after thinking ends and swaps the label it already owns.
///
/// Respects the platform reduced-motion setting by rendering static.
class FlowThinkingIndicator extends StatefulWidget {
  const FlowThinkingIndicator({
    super.key,
    this.label,
    this.active = true,
    this.color,
    this.size = 14,
    this.duration = const Duration(milliseconds: 2400),
    this.semanticLabel,
  }) : assert(size > 0, 'size must be positive');

  /// Host-localized text beside the glyph, e.g. 'Thinking…'.
  /// Null renders the glyph alone.
  final String? label;

  /// Whether the asterisk turns and breathes. False holds it still — the
  /// settled state.
  final bool active;

  /// Glyph ink. Defaults to `onSurfaceMuted`; the label always draws in the
  /// muted ink, a step below it, as in the design.
  final Color? color;

  /// Edge of the square glyph.
  final double size;

  /// One full cycle: a revolution and a breath, in step.
  final Duration duration;

  /// Accessibility label for the glyph-only form (e.g. a localized
  /// "Thinking"). Ignored when [label] is set — the visible text already
  /// carries the meaning.
  final String? semanticLabel;

  @override
  State<FlowThinkingIndicator> createState() => _FlowThinkingIndicatorState();
}

class _FlowThinkingIndicatorState extends State<FlowThinkingIndicator>
    with SingleTickerProviderStateMixin {
  /// How far the breath draws in: scale and ink at the bottom of the cycle.
  static const double _minScale = 0.8;
  static const double _minOpacity = 0.7;

  /// The design's gap between the glyph and its label.
  static const double _labelGap = 4;

  late final AnimationController _controller;

  /// One breath over the controller's full period — out and back with an
  /// eased turn at each end, resting at 0 so the settled glyph sits at
  /// full size and full ink.
  static final Animatable<double> _breath = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
  ]);

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
    // would restart the spin from upright and hitch it.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(FlowThinkingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration ||
        widget.active != oldWidget.active) {
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
    if (widget.active && !(_reduceMotion ?? false)) {
      // (Re)start so a changed duration takes effect immediately.
      _controller.repeat();
    } else {
      // Settled: upright and exhaled rather than frozen mid-cycle.
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final label = widget.label;

    final depth = _controller.drive(_breath);
    Widget glyph = RepaintBoundary(
      // One controller, two motions: a linear full turn per cycle and the
      // eased breath within it — the turn wraps at 1.0 exactly as the
      // breath lands back at rest, so the loop never visibly seams.
      child: RotationTransition(
        turns: _controller,
        child: ScaleTransition(
          scale: depth.drive(Tween<double>(begin: 1, end: _minScale)),
          child: FadeTransition(
            opacity: depth.drive(Tween<double>(begin: 1, end: _minOpacity)),
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _AsteriskPainter(
                color: widget.color ?? colors.onSurfaceMuted,
                // Proportional so the mark keeps its weight at any size.
                strokeWidth: widget.size / 9,
              ),
            ),
          ),
        ),
      ),
    );

    if (label == null) {
      final semanticLabel = widget.semanticLabel;
      if (semanticLabel == null) return glyph;
      return Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(child: glyph),
      );
    }

    // The visible text carries the meaning; announcing the glyph too would
    // only say it twice. The shimmer follows [active] on its own and rests
    // in the muted ink, so the settled line is exactly the design's static
    // one.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: glyph),
        const SizedBox(width: _labelGap),
        FlowShimmerText(
          text: label,
          enabled: widget.active,
          style: const TextStyle(height: 1.3),
        ),
      ],
    );
  }
}

/// The six-armed asterisk: three rounded strokes through the center. Drawn
/// rather than shipped — no SDK glyph matches the design's mark, and paint
/// stays crisp at any size and tint.
class _AsteriskPainter extends CustomPainter {
  const _AsteriskPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // A translucent ink would composite twice where the strokes cross,
    // darkening the hub against text in the same ink. Flatten the mark
    // into one layer and apply the ink's alpha to the whole glyph once.
    final translucent = color.a < 1;
    if (translucent) {
      canvas.saveLayer(
        (Offset.zero & size).inflate(strokeWidth),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: color.a),
      );
      paint.color = color.withValues(alpha: 1);
    }
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    for (var i = 0; i < 3; i++) {
      // Three diameters at 60° steps, starting upright so the resting mark
      // has the design's vertical arm.
      final angle = math.pi / 2 + math.pi * i / 3;
      final delta = Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(center - delta, center + delta, paint);
    }
    if (translucent) canvas.restore();
  }

  @override
  bool shouldRepaint(_AsteriskPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
