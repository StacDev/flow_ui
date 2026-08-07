import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/section_header.dart';

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
  const AddMenuPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLow,
        title: Text(
          'Add menu',
          style: typography.titleLarge.copyWith(color: colors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(spacing.lg),
        children: const [
          SectionHeader('Add menu'),
          DemoPreview(
            preview: _AddMenuDemo(),
            code: _addMenuSnippet,
          ),
        ],
      ),
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
