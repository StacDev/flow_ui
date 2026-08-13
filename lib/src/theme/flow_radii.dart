import 'package:flutter/material.dart';

/// Corner radius tokens for flow_ui components.
///
/// The five steps of the Flow UI design file: rows at 8, bubbles at 12,
/// tiles at 16, cards at 24, and pills.
@immutable
class FlowRadii {
  const FlowRadii({
    this.sm = const BorderRadius.all(Radius.circular(8)),
    this.md = const BorderRadius.all(Radius.circular(12)),
    this.lg = const BorderRadius.all(Radius.circular(16)),
    this.xl = const BorderRadius.all(Radius.circular(24)),
    this.full = const BorderRadius.all(Radius.circular(999)),
  });

  /// Rows and small controls: list items, badges, inline code, checkboxes.
  final BorderRadius sm;

  /// Bubbles, buttons, inputs, chips.
  final BorderRadius md;

  /// Attachment tiles and other medium cards.
  final BorderRadius lg;

  /// Raised cards: the composer, panels, sheets, modals.
  final BorderRadius xl;

  /// Fully rounded: pills, avatars, circular buttons.
  final BorderRadius full;

  FlowRadii copyWith({
    BorderRadius? sm,
    BorderRadius? md,
    BorderRadius? lg,
    BorderRadius? xl,
    BorderRadius? full,
  }) {
    return FlowRadii(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  FlowRadii lerp(FlowRadii? other, double t) {
    if (other == null) return this;
    return FlowRadii(
      sm: BorderRadius.lerp(sm, other.sm, t)!,
      md: BorderRadius.lerp(md, other.md, t)!,
      lg: BorderRadius.lerp(lg, other.lg, t)!,
      xl: BorderRadius.lerp(xl, other.xl, t)!,
      full: BorderRadius.lerp(full, other.full, t)!,
    );
  }
}
