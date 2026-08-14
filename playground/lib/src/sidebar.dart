import 'package:flutter/material.dart';

import 'playground_item.dart';
import 'shell_palette.dart';

/// The 214px navigation rail: an Examples section, then the component
/// list. The active row gets the tinted ground and the accent icon.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.selected, required this.onSelect});

  final PlaygroundItem selected;
  final ValueChanged<PlaygroundItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);
    final examples = PlaygroundItem.values.where((i) => i.isExample);
    final components = PlaygroundItem.values.where((i) => !i.isExample);

    return Container(
      width: 214,
      decoration: BoxDecoration(
        color: shell.sidebarBg,
        border: Border(right: BorderSide(color: shell.border)),
      ),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.first = false});

  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10, first ? 0 : 16, 10, 6),
      child: Text(
        label.toUpperCase(),
        style: shellText(
          size: 10.5,
          weight: FontWeight.w600,
          letterSpacing: 0.84,
          color: shell.sectionLabel,
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
    final shell = ShellPalette.of(context);

    final Color background;
    if (widget.active) {
      background = shell.navActiveBg;
    } else if (_hovered) {
      background = shell.navHover;
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
                color: widget.active ? shellAccent : shell.iconRest,
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
                    color: widget.active ? shell.text : shell.navText,
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
