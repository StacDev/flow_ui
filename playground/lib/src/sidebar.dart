import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'open_docs.dart';
import 'playground_item.dart';
import 'shell_text.dart';

/// The 214px navigation rail: an Examples section, then the component
/// list, and — on the web, where the docs share the origin — a Docs link
/// pinned at the bottom.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.selected, required this.onSelect});

  final PlaygroundItem selected;
  final ValueChanged<PlaygroundItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final examples = PlaygroundItem.values.where((i) => i.isExample);
    final components = PlaygroundItem.values.where((i) => !i.isExample);

    return Container(
      width: 214,
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        border: Border(right: BorderSide(color: colors.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              children: [
                const _SectionLabel('Examples', first: true),
                for (final item in examples)
                  _NavRow(
                    item: item,
                    active: item == selected,
                    onTap: () => onSelect(item),
                  ),
                const _SectionLabel('Components'),
                for (final item in components)
                  _NavRow(
                    item: item,
                    active: item == selected,
                    onTap: () => onSelect(item),
                  ),
              ],
            ),
          ),
          // The playground is served from /playground/ on the docs origin;
          // off the web there is no docs site (or browser tab) to go to.
          if (kIsWeb)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FooterLink(
                    icon: PhosphorIconsRegular.bookOpen,
                    label: 'Docs',
                    onTap: openDocs,
                  ),
                  const SizedBox(height: 1),
                  _FooterLink(
                    icon: PhosphorIconsRegular.package,
                    label: 'pub.dev',
                    onTap: () =>
                        openExternal('https://pub.dev/packages/flow_ui'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A pinned footer row: same rhythm as a nav row, with the outbound
/// arrow that marks it as leaving the playground.
class _FooterLink extends StatefulWidget {
  const _FooterLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? colors.surfaceContainerLow : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: _hovered ? colors.primary : colors.onSurfaceMuted,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shellText(
                    size: 13.5,
                    weight: FontWeight.w500,
                    color: _hovered
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsRegular.arrowUpRight,
                size: 13,
                color: colors.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.first = false});

  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10, first ? 0 : 16, 10, 6),
      child: Text(
        label.toUpperCase(),
        style: shellText(
          size: 10.5,
          weight: FontWeight.w600,
          letterSpacing: 0.84,
          color: context.flowColors.onSurfaceMuted,
        ),
      ),
    );
  }
}

class _NavRow extends StatefulWidget {
  const _NavRow({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final PlaygroundItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    final Color background;
    if (widget.active) {
      background = colors.surfaceContainer;
    } else if (_hovered) {
      background = colors.surfaceContainerLow;
    } else {
      background = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 15,
                color: widget.active ? colors.primary : colors.onSurfaceMuted,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shellText(
                    size: 13.5,
                    weight: FontWeight.w500,
                    color: widget.active
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
