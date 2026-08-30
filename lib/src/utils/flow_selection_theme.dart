import 'package:flutter/cupertino.dart' show CupertinoTheme;
import 'package:material_ui/material_ui.dart';

import '../theme/flow_theme.dart';

/// Text editing and selection in the Flow accent: the caret, the selection
/// wash and the handles, plus the Cupertino primary that iOS draws its
/// handles and toolbar with. Without this a host that installs [FlowTheme]
/// on a stock `ThemeData` gets Material's default purple caret against
/// Flow's primary — the one place the accent otherwise leaks through from
/// the host's `ColorScheme`.
class FlowSelectionTheme extends StatelessWidget {
  const FlowSelectionTheme({super.key, required this.child});

  final Widget child;

  /// The selection wash: the accent at Material's own 40%.
  static const double _selectionAlpha = 0.4;

  @override
  Widget build(BuildContext context) {
    final primary = context.flowColors.primary;
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withValues(alpha: _selectionAlpha),
        selectionHandleColor: primary,
      ),
      child: CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(primaryColor: primary),
        child: child,
      ),
    );
  }
}
