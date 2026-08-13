import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'gallery_scope.dart';

/// The shared gallery app bar: page title with an optional class-name
/// subtitle, the web/mobile viewport toggle, and the theme toggle — the
/// toggles read from [GalleryScope].
class GalleryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GalleryAppBar({super.key, required this.title, this.subtitle});

  /// The page title.
  final String title;

  /// The widget class this page demos, e.g. `FlowMenu`. Shown muted under
  /// the title — the metadata a reader scans for.
  final String? subtitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? kToolbarHeight : 64);

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final scope = GalleryScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: colors.surfaceContainerLow,
      toolbarHeight: preferredSize.height,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: typography.titleLarge.copyWith(color: colors.onSurface),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: typography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: scope.mobileView ? 'Web view' : 'Mobile view',
          onPressed: scope.onToggleViewport,
          icon: Icon(
            scope.mobileView
                ? Icons.desktop_windows_outlined
                : Icons.smartphone_outlined,
            color: colors.onSurfaceVariant,
          ),
        ),
        IconButton(
          tooltip: isDark ? 'Light theme' : 'Dark theme',
          onPressed: scope.onToggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
