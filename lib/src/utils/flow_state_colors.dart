import 'dart:ui' show Color;

// Interaction-state color math shared by the components.
// Not exported from the package barrel.

const double _disabledOpacity = 0.38;

/// [color] faded to the disabled treatment, preserving its own alpha.
Color flowDisabledColor(Color color) =>
    color.withValues(alpha: color.a * _disabledOpacity);
