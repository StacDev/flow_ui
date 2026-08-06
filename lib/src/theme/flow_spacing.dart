import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// Spacing scale tokens for flow_ui components.
///
/// Instance-based (not statics) so overall density can be tuned with
/// [copyWith] or a scaled instance.
@immutable
class FlowSpacing {
  const FlowSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  /// Tight gaps: icon-to-label, badge padding.
  final double xs;

  /// Small gaps: within compound controls.
  final double sm;

  /// Default gaps: bubble padding, list-item spacing.
  final double md;

  /// Section padding: screen edges, card interiors.
  final double lg;

  /// Large separation between sections.
  final double xl;

  /// Extra-large separation: empty states, page blocks.
  final double xxl;

  FlowSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return FlowSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  FlowSpacing lerp(FlowSpacing? other, double t) {
    if (other == null) return this;
    return FlowSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
    );
  }
}
