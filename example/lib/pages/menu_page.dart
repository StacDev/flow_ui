import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';

const String _menuSnippet = '''
FlowMenu(
  icon: Icons.add,
  tooltip: 'Add to chat',
  entries: [
    FlowMenuOption(
      id: 'files',
      icon: Icons.upload_file_outlined,
      label: 'Add Files or Photos',
    ),
    FlowMenuDivider(),
    // Non-empty children turn a row into a submenu — a pushed
    // page when presenting as a bottom sheet.
    FlowMenuOption(
      id: 'skills',
      icon: Icons.history_edu_outlined,
      label: 'Skills',
      children: [
        FlowMenuOption(id: 'slides', icon: Icons.co_present_outlined,
            label: 'Slide deck'),
        FlowMenuOption(id: 'review', icon: Icons.rate_review_outlined,
            label: 'Code review'),
      ],
    ),
    FlowMenuDivider(),
    // `selected` draws the check — a mode the host toggled on.
    FlowMenuOption(
      id: 'research',
      icon: Icons.school_outlined,
      label: 'Research',
      selected: researchOn,
    ),
    FlowMenuOption(
      id: 'web-search',
      icon: Icons.language_outlined,
      label: 'Web Search',
    ),
  ],
  onSelected: (id) => handle(id),
  // Presentation is automatic: an anchored menu on desktop, a
  // bottom sheet on iOS and Android. FlowMenuPresentation.menu /
  // .sheet force either.
  sheetTitle: 'Add to Chat',
)''';

/// Demo for [FlowMenu].
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Menu',
      className: 'FlowMenu',
      description:
          'A menu of options behind a single icon trigger: plain rows, '
          'grouped by dividers, submenus behind rows with children, and a '
          'check on modes the host has toggled on. The composer\'s "+" menu '
          'is this widget with the add glyph. Presentation follows the '
          'platform — an anchored menu here, a bottom sheet on phones: '
          'toggle the gallery\'s mobile view to see it.',
      children: [DemoPreview(preview: _MenuDemo(), code: _menuSnippet)],
    );
  }
}

class _MenuDemo extends StatefulWidget {
  const _MenuDemo();

  @override
  State<_MenuDemo> createState() => _MenuDemoState();
}

class _MenuDemoState extends State<_MenuDemo> {
  bool _researchOn = true;

  void _handle(String id) {
    if (id == 'research') {
      setState(() => _researchOn = !_researchOn);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Add to chat: $id'),
          behavior: SnackBarBehavior.floating,
          width: 240,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FlowMenu(
      icon: Icons.add,
      tooltip: 'Add to chat',
      // Left on the `auto` default: the gallery's phone frame reports a
      // mobile platform, so the same widget anchors a menu out here and
      // presents a sheet in there.
      sheetTitle: 'Add to Chat',
      entries: [
        const FlowMenuOption(
          id: 'files',
          icon: Icons.upload_file_outlined,
          label: 'Add Files or Photos',
        ),
        const FlowMenuDivider(),
        const FlowMenuOption(
          id: 'skills',
          icon: Icons.history_edu_outlined,
          label: 'Skills',
          children: [
            FlowMenuOption(
              id: 'slides',
              icon: Icons.co_present_outlined,
              label: 'Slide deck',
            ),
            FlowMenuOption(
              id: 'review',
              icon: Icons.rate_review_outlined,
              label: 'Code review',
            ),
          ],
        ),
        const FlowMenuOption(
          id: 'connectors',
          icon: Icons.power_outlined,
          label: 'Connectors',
          children: [
            FlowMenuOption(
              id: 'drive',
              icon: Icons.add_to_drive_outlined,
              label: 'Google Drive',
            ),
            FlowMenuOption(
              id: 'calendar',
              icon: Icons.calendar_month_outlined,
              label: 'Calendar',
            ),
          ],
        ),
        const FlowMenuDivider(),
        FlowMenuOption(
          id: 'research',
          icon: Icons.school_outlined,
          label: 'Research',
          selected: _researchOn,
        ),
        const FlowMenuOption(
          id: 'web-search',
          icon: Icons.language_outlined,
          label: 'Web Search',
        ),
      ],
      onSelected: _handle,
    );
  }
}
