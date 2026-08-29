import 'package:material_ui/material_ui.dart';

import '../styles/flow_menu_style.dart';
import '../theme/flow_theme.dart';
import '../widgets/flow_menu.dart'
    show FlowMenuDivider, FlowMenuEntry, FlowMenuOption;
import 'flow_menu_core.dart';
import 'flow_menu_sheet.dart';

/// The rows an anchored menu card draws for [entries]: options as
/// [FlowMenuRow]s, dividers as rules, options with children as submenus.
/// Shared by [FlowMenu]'s trigger menu and the message menu, so a host's
/// one `entries` list reads the same wherever it is opened from.
List<Widget> flowMenuEntryRows(
  BuildContext context,
  List<FlowMenuEntry> entries, {
  FlowMenuStyle? style,
  required ValueChanged<String> onSelected,
}) {
  FlowMenuRow optionRow(FlowMenuOption option) => FlowMenuRow(
    label: option.label,
    icon: option.icon,
    selected: option.selected,
    enabled: option.enabled,
    style: style,
    onTap: () => onSelected(option.id),
  );
  return [
    for (final entry in entries)
      switch (entry) {
        FlowMenuDivider() => FlowMenuRule(style: style),
        FlowMenuOption(children: []) => optionRow(entry),
        FlowMenuOption() => FlowSubmenuRow(
          style: style,
          menuChildren: [
            FlowMenuCard(
              style: style,
              children: [for (final child in entry.children) optionRow(child)],
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.icon != null) ...[
                Icon(
                  entry.icon,
                  size: 18,
                  color: entry.enabled
                      ? (style?.iconColor ??
                            context.flowColors.onSurfaceVariant)
                      : context.flowColors.onSurfaceDisabled,
                ),
                const SizedBox(width: flowMenuIconGap),
              ],
              Text(
                entry.label,
                style: flowMenuLabelStyle(context, large: false, style: style),
              ),
            ],
          ),
        ),
      },
  ];
}

/// Opens [entries] as the phone sheet, options with children pushing a
/// page of their own.
Future<void> showFlowMenuEntriesSheet({
  required BuildContext context,
  required List<FlowMenuEntry> entries,
  FlowMenuStyle? style,
  String? title,
  required ValueChanged<String> onSelected,
}) {
  FlowMenuRow optionRow(FlowMenuOption option) => FlowMenuRow(
    label: option.label,
    icon: option.icon,
    selected: option.selected,
    enabled: option.enabled,
    large: true,
    style: style,
    onTap: () => onSelected(option.id),
  );
  return showFlowMenuSheet(
    context: context,
    style: style,
    root: FlowMenuSheetPage(
      title: title,
      children: (context) => [
        for (final entry in entries)
          switch (entry) {
            FlowMenuDivider() => FlowMenuRule(style: style, large: true),
            FlowMenuOption(children: []) => optionRow(entry),
            FlowMenuOption() => FlowMenuRow(
              label: entry.label,
              icon: entry.icon,
              enabled: entry.enabled,
              showChevron: true,
              large: true,
              style: style,
              closeOnTap: false,
              onTap: () => FlowMenuSheetScope.maybeOf(context)?.push(
                FlowMenuSheetPage(
                  title: entry.label,
                  children: (context) => [
                    for (final child in entry.children) optionRow(child),
                  ],
                ),
              ),
            ),
          },
      ],
    ),
  );
}
