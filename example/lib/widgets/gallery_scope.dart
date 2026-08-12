import 'package:flutter/widgets.dart';

/// Gallery-wide view state: the web/mobile viewport and the theme toggle.
///
/// Installed above the navigator (via `MaterialApp.builder`), so every pushed
/// page reads the same state and the toggles keep working across navigation.
class GalleryScope extends InheritedWidget {
  const GalleryScope({
    super.key,
    required this.mobileView,
    required this.onToggleViewport,
    required this.onToggleTheme,
    required super.child,
  });

  /// Whether pages render inside the phone frame.
  final bool mobileView;

  /// Flips [mobileView].
  final VoidCallback onToggleViewport;

  /// Flips the app between light and dark.
  final VoidCallback onToggleTheme;

  static GalleryScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GalleryScope>();
    assert(scope != null, 'GalleryScope is missing above this context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(GalleryScope oldWidget) =>
      mobileView != oldWidget.mobileView;
}
