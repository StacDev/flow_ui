import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/section_header.dart';

const String _composerSnippet = '''
FlowComposer(
  placeholder: 'Message flow_ui…',
  isStreaming: generating,
  onSend: (text) => startGeneration(text),
  onStop: cancelGeneration,
  leadingActions: [
    FlowAddMenu(
      tooltip: 'Add to chat',
      options: [
        FlowAddOption(
          id: 'photos', icon: Icons.image_outlined, label: 'Photos'),
        FlowAddOption(
          id: 'files', icon: Icons.upload_file_outlined, label: 'Files'),
      ],
      onSelected: (id) => pickAttachment(id),
    ),
  ],
  trailingActions: [
    FlowModelSelector(
      models: [
        FlowModelOption(id: 'sonnet', label: 'Sonnet 5'),
        FlowModelOption(id: 'opus', label: 'Opus 5'),
      ],
      selectedId: modelId,
      onSelected: (id) => setModel(id),
    ),
  ],
)''';

/// Demo for [FlowComposer], composed with both selectors.
class ComposerPage extends StatelessWidget {
  const ComposerPage({super.key, required this.onToggleTheme});

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
          'Message composer',
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
          SectionHeader('Composer'),
          DemoPreview(
            minHeight: 220,
            preview: _ComposerDemo(),
            code: _composerSnippet,
          ),
        ],
      ),
    );
  }
}

class _ComposerDemo extends StatefulWidget {
  const _ComposerDemo();

  @override
  State<_ComposerDemo> createState() => _ComposerDemoState();
}

class _ComposerDemoState extends State<_ComposerDemo> {
  final List<String> _sent = [];
  String _modelId = 'sonnet';
  bool _generating = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _send(String text) {
    _timer?.cancel();
    setState(() {
      _sent.add(text);
      _generating = true;
    });
    // Pretend to generate for a bit so the stop button shows.
    _timer = Timer(const Duration(milliseconds: 2500), () {
      setState(() => _generating = false);
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _generating = false);
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: 240,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlowComposer(
          placeholder: 'Message flow_ui…',
          isStreaming: _generating,
          onSend: _send,
          onStop: _stop,
          leadingActions: [
            FlowAddMenu(
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
                  id: 'camera',
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                ),
              ],
              onSelected: (id) => _notify('Add to chat: $id'),
            ),
          ],
          trailingActions: [
            FlowModelSelector(
              tooltip: 'Choose model',
              models: const [
                FlowModelOption(
                  id: 'sonnet',
                  label: 'Sonnet 5',
                  description: 'Fast and balanced',
                ),
                FlowModelOption(
                  id: 'opus',
                  label: 'Opus 5',
                  description: 'Most capable',
                ),
              ],
              selectedId: _modelId,
              onSelected: (id) => setState(() => _modelId = id),
            ),
          ],
        ),
        if (_sent.isNotEmpty) ...[
          SizedBox(height: spacing.lg),
          Text(
            'Sent ($_modelId):',
            style: typography.labelMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.xs),
          for (final text in _sent)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xs),
              child: Text(
                '• $text',
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
