import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Reserves a finger's reach around a small control on touch platforms.
/// The design draws message actions on a 20px frame and the composer's
/// glyph buttons on 24–32px discs; a finger needs 44 (Apple) to 48
/// (Material). Every ancestor rejects a pointer outside its own box before
/// its children are asked, so the reach has to exist in layout: this lays
/// out at least [minWidth] by [minHeight], seats the child with [topShare]
/// of the spare height above it, and routes a hit anywhere in the box to
/// the child's centre — Material's own tap-target padding.
///
/// Sized per site rather than a flat 44, and absorbed from the gap beside
/// the control where one exists — the message strip grows up into the
/// footer gap, the composer's attach into the row inset — so the drawn
/// frames stay where the design put them.
///
/// A pointer platform passes straight through, by the theme's platform as
/// the menus and the composer resolve it, so hosts and tests can steer it.
class FlowTouchTarget extends SingleChildRenderObjectWidget {
  const FlowTouchTarget({
    super.key,
    this.minWidth = 44,
    this.minHeight = 44,
    this.topShare = 0.5,
    this.leftShare = 0.5,
    required Widget super.child,
  });

  final double minWidth;
  final double minHeight;

  /// How much of the spare height sits above the child, 0–1.
  final double topShare;

  /// How much of the spare width sits left of the child, 0–1: a strip's
  /// first button keeps its frame at the strip's start, its last at the
  /// end.
  final double leftShare;

  /// Whether the theme's platform is one driven by touch.
  static bool isTouch(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }

  @override
  RenderFlowTouchTarget createRenderObject(BuildContext context) {
    final touch = isTouch(context);
    return RenderFlowTouchTarget(
      minWidth: touch ? minWidth : 0,
      minHeight: touch ? minHeight : 0,
      topShare: topShare,
      leftShare: leftShare,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFlowTouchTarget renderObject,
  ) {
    final touch = isTouch(context);
    renderObject
      ..minWidth = touch ? minWidth : 0
      ..minHeight = touch ? minHeight : 0
      ..topShare = topShare
      ..leftShare = leftShare;
  }
}

/// The render side of [FlowTouchTarget]: the child's size grown to the
/// minimums, the child seated inside, every hit in the box the child's.
class RenderFlowTouchTarget extends RenderShiftedBox {
  RenderFlowTouchTarget({
    required this._minWidth,
    required this._minHeight,
    required this._topShare,
    required this._leftShare,
    RenderBox? child,
  }) : super(child);

  double _minWidth;
  set minWidth(double value) {
    if (value == _minWidth) return;
    _minWidth = value;
    markNeedsLayout();
  }

  double _minHeight;
  set minHeight(double value) {
    if (value == _minHeight) return;
    _minHeight = value;
    markNeedsLayout();
  }

  double _topShare;
  set topShare(double value) {
    if (value == _topShare) return;
    _topShare = value;
    markNeedsLayout();
  }

  double _leftShare;
  set leftShare(double value) {
    if (value == _leftShare) return;
    _leftShare = value;
    markNeedsLayout();
  }

  Size _reserve(Size childSize) => Size(
    math.max(childSize.width, _minWidth),
    math.max(childSize.height, _minHeight),
  );

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(child?.getMinIntrinsicWidth(height) ?? 0, _minWidth);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(child?.getMaxIntrinsicWidth(height) ?? 0, _minWidth);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(child?.getMinIntrinsicHeight(width) ?? 0, _minHeight);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(child?.getMaxIntrinsicHeight(width) ?? 0, _minHeight);

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    _reserve(child?.getDryLayout(constraints) ?? Size.zero),
  );

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.constrain(_reserve(Size.zero));
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(_reserve(child.size));
    (child.parentData! as BoxParentData).offset = Offset(
      (size.width - child.size.width) * _leftShare,
      (size.height - child.size.height) * _topShare,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    final child = this.child;
    if (child == null || !size.contains(position)) return false;
    // In the reach but off the control: the hit lands on the child's
    // centre, Material's own rule, so the control's gesture and ink take
    // it whatever frame or ring sits around them.
    final center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => child.hitTest(result, position: center),
    );
  }
}
