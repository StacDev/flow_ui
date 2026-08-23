import 'package:material_ui/material_ui.dart';

/// Host overrides for [FlowMessage]'s look, on top of the theme tokens.
///
/// Every field is optional; null falls back to the token-derived default
/// noted on the field. Install one on [FlowTheme.messageStyle] to restyle
/// every message; a widget's own `style` wins field by field:
///
/// ```dart
/// FlowMessage(
///   message,
///   style: const FlowMessageStyle(bubbleColor: Color(0x14336699)),
/// )
/// ```
@immutable
class FlowMessageStyle {
  const FlowMessageStyle({this.bubbleColor, this.bubbleTextColor});

  /// The user bubble's fill. Defaults to ink at 4%. A failed user turn
  /// keeps the theme's `errorContainer` regardless.
  final Color? bubbleColor;

  /// The user bubble's ink. Defaults to `onSurface`. A failed user turn
  /// keeps the theme's `onErrorContainer` regardless.
  final Color? bubbleTextColor;

  /// A copy where [other]'s fields win over this style's.
  FlowMessageStyle merge(FlowMessageStyle? other) {
    if (other == null) return this;
    return FlowMessageStyle(
      bubbleColor: other.bubbleColor ?? bubbleColor,
      bubbleTextColor: other.bubbleTextColor ?? bubbleTextColor,
    );
  }

  /// Linear interpolation, for theme transitions. A null [other] returns
  /// this style unchanged.
  FlowMessageStyle lerp(FlowMessageStyle? other, double t) {
    if (other == null) return this;
    return FlowMessageStyle(
      bubbleColor: Color.lerp(bubbleColor, other.bubbleColor, t),
      bubbleTextColor: Color.lerp(bubbleTextColor, other.bubbleTextColor, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowMessageStyle &&
        other.bubbleColor == bubbleColor &&
        other.bubbleTextColor == bubbleTextColor;
  }

  @override
  int get hashCode => Object.hash(bubbleColor, bubbleTextColor);
}
