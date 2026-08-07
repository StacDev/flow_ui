import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/section_header.dart';

const String _selectorSnippet = '''
FlowModelSelector(
  tooltip: 'Choose model',
  models: [
    FlowModelOption(
      id: 'sonnet-5',
      label: 'Sonnet 5',
      description: 'Fast and balanced',
    ),
    FlowModelOption(
      id: 'opus-5',
      label: 'Opus 5',
      description: 'Most capable',
    ),
    FlowModelOption(
      id: 'haiku-4-5',
      label: 'Haiku 4.5',
      description: 'Fastest',
    ),
    FlowModelOption(id: 'legacy', label: 'Legacy', enabled: false),
  ],
  selectedId: selectedModelId,
  onSelected: (id) => setModel(id),
)''';

/// Demo for [FlowModelSelector].
class ModelSelectorPage extends StatelessWidget {
  const ModelSelectorPage({super.key, required this.onToggleTheme});

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
          'Model selector',
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
          SectionHeader('Model selector'),
          DemoPreview(
            preview: _SelectorDemo(),
            code: _selectorSnippet,
          ),
        ],
      ),
    );
  }
}

class _SelectorDemo extends StatefulWidget {
  const _SelectorDemo();

  @override
  State<_SelectorDemo> createState() => _SelectorDemoState();
}

class _SelectorDemoState extends State<_SelectorDemo> {
  String _selectedId = 'sonnet-5';

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowModelSelector(
          tooltip: 'Choose model',
          models: const [
            FlowModelOption(
              id: 'sonnet-5',
              label: 'Sonnet 5',
              description: 'Fast and balanced',
            ),
            FlowModelOption(
              id: 'opus-5',
              label: 'Opus 5',
              description: 'Most capable',
            ),
            FlowModelOption(
              id: 'haiku-4-5',
              label: 'Haiku 4.5',
              description: 'Fastest',
            ),
            FlowModelOption(id: 'legacy', label: 'Legacy', enabled: false),
          ],
          selectedId: _selectedId,
          onSelected: (id) => setState(() => _selectedId = id),
        ),
        SizedBox(height: spacing.lg),
        Text(
          'Selected: $_selectedId',
          style: typography.bodySmall.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
