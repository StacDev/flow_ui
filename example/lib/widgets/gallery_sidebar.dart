import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

/// One component in the gallery: what the sidebar lists and the preview
/// pane renders.
class GalleryEntry {
  const GalleryEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  /// The component name, shown in the sidebar and used as the page title.
  final String title;

  /// One line on what the component is, for the narrow-window list.
  final String subtitle;

  /// The sidebar and tile glyph.
  final IconData icon;

  /// Builds the component's page (its own Scaffold + app bar), which is the
  /// preview pane on wide windows and the pushed route on narrow ones.
  final WidgetBuilder builder;
}

/// A labelled group of gallery entries.
class GalleryGroup {
  const GalleryGroup({required this.label, required this.entries});

  /// The section caption, e.g. 'Conversation'.
  final String label;

  final List<GalleryEntry> entries;
}

/// The left navigation: the gallery lockup over grouped components.
class GallerySidebar extends StatelessWidget {
  const GallerySidebar({
    super.key,
    required this.groups,
    required this.selected,
    required this.onSelect,
  });

  /// Width of the pane, fixed so the preview gets the rest.
  static const double width = 272;

  final List<GalleryGroup> groups;
  final GalleryEntry selected;
  final ValueChanged<GalleryEntry> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(right: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: const _Lockup(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              children: [
                for (final group in groups) ...[
                  _GroupLabel(group.label),
                  for (final entry in group.entries)
                    _SidebarItem(
                      entry: entry,
                      selected: entry == selected,
                      onTap: () => onSelect(entry),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The wordmark: a primary-filled mark, the name, and the version chip.
class _Lockup extends StatelessWidget {
  const _Lockup();

  /// Keep in sync with pubspec.yaml.
  static const String _version = 'v0.0.1';

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Icon(Icons.bolt_rounded, size: 18, color: colors.onPrimary),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'flow_ui',
            overflow: TextOverflow.ellipsis,
            style: context.flowTypography.titleLarge.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            _version,
            style: context.flowTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Text(
        label.toUpperCase(),
        style: context.flowTypography.labelSmall.copyWith(
          color: context.flowColors.onSurfaceVariant,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final GalleryEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? colors.primaryContainer : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected ? null : onTap,
          hoverColor: colors.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(
                  entry.icon,
                  size: 18,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.flowTypography.labelLarge.copyWith(
                      color: selected
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
