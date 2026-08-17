import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

const String addToChatSnippet = '''
FlowMenu(
  icon: PhosphorIconsRegular.plus,
  tooltip: 'Add to chat',
  // Anchored menu on desktop; a bottom sheet on phones, where
  // submenus push pages under this title.
  sheetTitle: 'Add to Chat',
  entries: [
    const FlowMenuOption(
      id: 'files',
      icon: PhosphorIconsRegular.file,
      label: 'Add Files or Photos',
    ),
    const FlowMenuDivider(),
    const FlowMenuOption(
      id: 'skills',
      icon: PhosphorIconsRegular.scroll,
      label: 'Skills',
      children: [...], // a row with children opens a submenu
    ),
    const FlowMenuOption(
      id: 'connectors',
      icon: PhosphorIconsRegular.lightning,
      label: 'Connectors',
      children: [...],
    ),
    const FlowMenuDivider(),
    FlowMenuOption(
      id: 'research',
      icon: PhosphorIconsRegular.graduationCap,
      label: 'Research',
      selected: researchOn, // draws the accent check
    ),
    FlowMenuOption(
      id: 'web-search',
      icon: PhosphorIconsRegular.globe,
      label: 'Web Search',
      selected: webSearchOn,
    ),
  ],
  onSelected: toggleTool,
)''';

/// The add-to-chat menu behind its plus trigger, live: Skills and
/// Connectors open submenus, Research and Web Search toggle their checks.
class AddToChatDemo extends StatefulWidget {
  const AddToChatDemo({super.key});

  @override
  State<AddToChatDemo> createState() => _AddToChatDemoState();
}

class _AddToChatDemoState extends State<AddToChatDemo> {
  bool _researchOn = true;
  bool _webSearchOn = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlowMenu(
        icon: PhosphorIconsRegular.plus,
        tooltip: 'Add to chat',
        sheetTitle: 'Add to Chat',
        entries: [
          const FlowMenuOption(
            id: 'files',
            icon: PhosphorIconsRegular.file,
            label: 'Add Files or Photos',
          ),
          const FlowMenuDivider(),
          const FlowMenuOption(
            id: 'skills',
            icon: PhosphorIconsRegular.scroll,
            label: 'Skills',
            children: [
              FlowMenuOption(id: 'skill-writer', label: 'Blog Writer'),
              FlowMenuOption(id: 'skill-review', label: 'Code Review'),
              FlowMenuOption(id: 'skill-planner', label: 'Trip Planner'),
            ],
          ),
          const FlowMenuOption(
            id: 'connectors',
            icon: PhosphorIconsRegular.lightning,
            label: 'Connectors',
            children: [
              FlowMenuOption(id: 'conn-drive', label: 'Google Drive'),
              FlowMenuOption(id: 'conn-github', label: 'GitHub'),
            ],
          ),
          const FlowMenuDivider(),
          FlowMenuOption(
            id: 'research',
            icon: PhosphorIconsRegular.graduationCap,
            label: 'Research',
            selected: _researchOn,
          ),
          FlowMenuOption(
            id: 'web-search',
            icon: PhosphorIconsRegular.globe,
            label: 'Web Search',
            selected: _webSearchOn,
          ),
        ],
        onSelected: (id) {
          if (id == 'research') {
            setState(() => _researchOn = !_researchOn);
          } else if (id == 'web-search') {
            setState(() => _webSearchOn = !_webSearchOn);
          }
        },
      ),
    );
  }
}
