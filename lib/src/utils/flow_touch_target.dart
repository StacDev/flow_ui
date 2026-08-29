import 'package:flutter/rendering.dart'
    show BoxHitTestEntry, BoxHitTestResult, RenderProxyBox;
import 'package:material_ui/material_ui.dart';

/// Widens a small control's hit area on touch platforms without changing
/// its layout. The design draws message actions on a 20px frame and the
/// composer's glyph buttons on 24–32px discs; a finger needs 44 (Apple) to
/// 48 (Material) and neither guideline is met by the frame alone. Material
/// reserves that space in layout, which would open the rows up; this keeps
/// the drawn size and accepts hits from the surrounding [minWidth] by
/// [minHeight], [topShare] of the vertical extension above the child and
/// the rest below.
///
/// Sized per site rather than a flat 44: a hit area that reaches into a
/// neighbouring control steals its taps, since siblings are hit-tested in
/// reverse order rather than by distance. A row of 20px actions on a 4px
/// pitch keeps [minWidth] at 24 and takes its reach vertically.
///
/// A pointer platform passes straight through, by the theme's platform as
/// the menus and the composer resolve it, so hosts and tests can steer it.
class FlowTouchTarget extends SingleChildRenderObjectWidget {
  const FlowTouchTarget({
    super.key,
    this.minWidth = 44,
    this.minHeight = 44,
    this.topShare = 0.5,
    required Widget super.child,
  });

  final double minWidth;
  final double minHeight;

  /// How much of the vertical extension sits above the child, 0–1.
  final double topShare;

  static bool _touch(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }

  @override
  RenderFlowTouchTarget createRenderObject(BuildContext context) {
    final touch = _touch(context);
    return RenderFlowTouchTarget(
      minWidth: touch ? minWidth : 0,
      minHeight: touch ? minHeight : 0,
      topShare: topShare,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFlowTouchTarget renderObject,
  ) {
    final touch = _touch(context);
    renderObject
      ..minWidth = touch ? minWidth : 0
      ..minHeight = touch ? minHeight : 0
      ..topShare = topShare;
  }
}

/// The render side of [FlowTouchTarget]: lays out as its child and accepts
/// hits from the wider reach.
class RenderFlowTouchTarget extends RenderProxyBox {
  RenderFlowTouchTarget({
    required this.minWidth,
    required this.minHeight,
    required this.topShare,
  });

  double minWidth;
  double minHeight;
  double topShare;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final extraX = (minWidth - size.width).clamp(0.0, double.infinity);
    final extraY = (minHeight - size.height).clamp(0.0, double.infinity);
    final reach = Rect.fromLTRB(
      -extraX / 2,
      -extraY * topShare,
      size.width + extraX / 2,
      size.height + extraY * (1 - topShare),
    );
    if (!reach.contains(position)) return false;
    // A hit outside the child's own bounds lands on its nearest edge, so
    // the control's gesture and ink both accept it.
    final inside = Offset(
      position.dx.clamp(0.0, size.width - 0.01),
      position.dy.clamp(0.0, size.height - 0.01),
    );
    if (hitTestChildren(result, position: inside)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
