import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';

const String _addMenuSnippet = '''
FlowAddMenu(
  tooltip: 'Add to chat',
  options: [
    FlowAddOption(
      id: 'photos',
      icon: Icons.image_outlined,
      label: 'Photos',
    ),
    FlowAddOption(
      id: 'files',
      icon: Icons.upload_file_outlined,
      label: 'Files',
    ),
    FlowAddOption(
      id: 'web-search',
      icon: Icons.language_outlined,
      label: 'Web search',
    ),
    FlowAddOption(
      id: 'camera',
      icon: Icons.camera_alt_outlined,
      label: 'Camera',
      enabled: false,
    ),
  ],
  onSelected: (id) => handleAdd(id),
)''';

/// Demo for [FlowAddMenu].
class AddMenuPage extends StatelessWidget {
  const AddMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Add menu',
      className: 'FlowAddMenu',
      description:
          'Attachments and tools behind a single "+" trigger. Tap it — the '
          'menu closes on selection, and disabled options render muted.',
      children: [DemoPreview(preview: _AddMenuDemo(), code: _addMenuSnippet)],
    );
  }
}

class _AddMenuDemo extends StatelessWidget {
  const _AddMenuDemo();

  @override
  Widget build(BuildContext context) {
    return FlowAddMenu(
      tooltip: 'Add to chat',
      options: const [
        FlowAddOption(
          id: 'photos',
          icon: Icons.image_outlined,
          label: 'Photos',
        ),
        FlowAddOption(
          id: 'files',
          icon: Icons.upload_file_outlined,
          label: 'Files',
        ),
        FlowAddOption(
          id: 'web-search',
          icon: Icons.language_outlined,
          label: 'Web search',
        ),
        FlowAddOption(
          id: 'camera',
          icon: Icons.camera_alt_outlined,
          label: 'Camera',
          enabled: false,
        ),
      ],
      onSelected: (id) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Add to chat: $id'),
              behavior: SnackBarBehavior.floating,
              width: 220,
            ),
          );
      },
    );
  }
}
