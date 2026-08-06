import 'package:flutter/material.dart';

/// Corner radius tokens for flow_ui components.
@immutable
class FlowRadii {
  const FlowRadii({
    this.sm = const BorderRadius.all(Radius.circular(6)),
    this.md = const BorderRadius.all(Radius.circular(10)),
    this.lg = const BorderRadius.all(Radius.circular(16)),
    this.full = const BorderRadius.all(Radius.circular(999)),
  });

  /// Small controls: badges, inline code, checkboxes.
  final BorderRadius sm;

  /// Buttons, inputs, chips.
  final BorderRadius md;

  /// Bubbles, cards, panels, modals.
  final BorderRadius lg;

  /// Fully rounded: pills, avatars, circular buttons.
  final BorderRadius full;

  FlowRadii copyWith({
    BorderRadius? sm,
    BorderRadius? md,
    BorderRadius? lg,
    BorderRadius? full,
  }) {
    return FlowRadii(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      full: full ?? this.full,
    );
  }

  FlowRadii lerp(FlowRadii? other, double t) {
    if (other == null) return this;
    return FlowRadii(
      sm: BorderRadius.lerp(sm, other.sm, t)!,
      md: BorderRadius.lerp(md, other.md, t)!,
      lg: BorderRadius.lerp(lg, other.lg, t)!,
      full: BorderRadius.lerp(full, other.full, t)!,
    );
  }
}
