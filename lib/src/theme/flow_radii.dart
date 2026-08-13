import 'package:flutter/material.dart';

/// Corner radius tokens for flow_ui components.
///
/// The four steps of the Flow UI design file: rows at 8, bubbles at 12,
/// cards at 24, and pills.
@immutable
class FlowRadii {
  const FlowRadii({
    this.sm = const BorderRadius.all(Radius.circular(8)),
    this.md = const BorderRadius.all(Radius.circular(12)),
    this.lg = const BorderRadius.all(Radius.circular(24)),
    this.full = const BorderRadius.all(Radius.circular(999)),
  });

  /// Rows and small controls: list items, badges, inline code, checkboxes.
  final BorderRadius sm;

  /// Bubbles, buttons, inputs, chips, attachment tiles.
  final BorderRadius md;

  /// Raised cards: the composer, panels, sheets, modals.
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
