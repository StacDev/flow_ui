import 'dart:ui' show Color;

// Interaction-state color math shared by the components.
// Not exported from the package barrel.

const double _disabledOpacity = 0.38;
const double _scrimOpacity = 0.85;

/// [color] faded to the disabled treatment, preserving its own alpha.
Color flowDisabledColor(Color color) =>
    color.withValues(alpha: color.a * _disabledOpacity);

/// [color] as a scrim disc over image content.
///
/// Unlike [flowDisabledColor] this *sets* alpha rather than scaling it — the
/// point is a predictable frosted chip over pixels the package can't see.
Color flowScrimColor(Color color) => color.withValues(alpha: _scrimOpacity);
