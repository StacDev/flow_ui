import 'package:material_ui/material_ui.dart';

import '../theme/flow_theme.dart';

/// Text with a soft highlight sweeping through it — the waiting treatment
/// for a label whose work is still in flight, e.g. a thinking line or a
/// tool call in progress.
///
/// ```dart
/// FlowShimmerText(text: 'Searching the web…')
/// ```
///
/// The glyphs rest in [baseColor] while a band of [highlightColor] slides
/// across; with [enabled] false — or reduced motion on — the text renders
/// statically in the base ink, so the same widget can stay in place once
/// the work settles.
class FlowShimmerText extends StatefulWidget {
  const FlowShimmerText({
    super.key,
    required this.text,
    this.enabled = true,
    this.style,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 2400),
    this.textAlign,
  });

  /// The text to draw.
  final String text;

  /// Whether the highlight sweeps. False renders plain static text.
  final bool enabled;

  /// Merged over the default `bodyLarge` + [baseColor] style. Its color, if
  /// set, only shows while static — the sweep draws with [baseColor] and
  /// [highlightColor].
  final TextStyle? style;

  /// Resting ink. Defaults to `onSurfaceMuted`.
  final Color? baseColor;

  /// The sweeping band. Defaults to `onSurface`.
  final Color? highlightColor;

  /// One full sweep across the text.
  final Duration duration;

  final TextAlign? textAlign;

  @override
  State<FlowShimmerText> createState() => _FlowShimmerTextState();
}

class _FlowShimmerTextState extends State<FlowShimmerText>
    with SingleTickerProviderStateMixin {
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
    // would restart the sweep and hitch it.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(FlowShimmerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration ||
        widget.enabled != oldWidget.enabled) {
      _controller.duration = widget.duration;
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _animating => widget.enabled && !(_reduceMotion ?? false);

  void _syncAnimation() {
    if (_animating) {
      // (Re)start so a changed duration takes effect immediately.
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final baseColor = widget.baseColor ?? colors.onSurfaceMuted;
    final baseStyle = context.flowTypography.bodyLarge.copyWith(
      color: baseColor,
    );
    final style = widget.style == null
        ? baseStyle
        : baseStyle.merge(widget.style);

    if (!_animating) {
      return Text(widget.text, style: style, textAlign: widget.textAlign);
    }

    final highlightColor = widget.highlightColor ?? colors.onSurface;

    // The mask multiplies the gradient by the child's alpha, so the child
    // paints opaque: a translucent ink there would dim the whole line a
    // second time on top of the gradient's own alpha.
    final child = Text(
      widget.text,
      style: style.copyWith(color: const Color(0xFFFFFFFF)),
      textAlign: widget.textAlign,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [baseColor, highlightColor, baseColor],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlidingGradient(_controller.value),
          ).createShader(bounds),
          child: child,
        ),
      ),
    );
  }
}

/// Slides the gradient one full width past each edge, so the band enters
/// from off-text and leaves off-text — the repeat's wrap lands while the
/// highlight is invisible and the loop never visibly jumps.
class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (2 * progress - 1), 0, 0);
}
