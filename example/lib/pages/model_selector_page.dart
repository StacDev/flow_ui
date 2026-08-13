import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';

const String _selectorSnippet = '''
FlowModelSelector(
  tooltip: 'Choose model',
  models: [
    FlowModelOption(
      id: 'fable-5',
      label: 'Fable 5',
      description: 'Our flagship model',
    ),
    FlowModelOption(
      id: 'opus-5-1',
      label: 'Opus 5.1',
      description: 'For complex & thinking tasks',
    ),
    FlowModelOption(
      id: 'haiku-4-5',
      label: 'Haiku 4.5',
      description: 'Fastest for quick answers',
    ),
  ],
  selectedId: selectedModelId,
  onSelected: (id) => setModel(id),
  // Optional: an Effort section. Picking a model or an effort
  // applies immediately and closes the menu.
  efforts: [
    FlowEffortOption(
      id: 'low',
      label: 'Low',
      description: 'Quickest replies. Simple answers',
    ),
    FlowEffortOption(
      id: 'max',
      label: 'Max',
      description: 'Complex, extensive tasks',
    ),
  ],
  selectedEffortId: selectedEffortId,
  onEffortSelected: (id) => setEffort(id),
  // Optional: overflow models behind a 'More models' row.
  moreModels: [
    FlowModelOption(id: 'sonnet-4-5', label: 'Sonnet 4.5'),
  ],
  // Presentation is automatic: an anchored menu on desktop, a
  // bottom sheet on iOS and Android. FlowMenuPresentation.menu /
  // .sheet force either.
  sheetTitle: 'Select model',
)''';

const List<FlowModelOption> _models = [
  FlowModelOption(
    id: 'fable-5',
    label: 'Fable 5',
    description: 'Our flagship model',
  ),
  FlowModelOption(
    id: 'opus-5-1',
    label: 'Opus 5.1',
    description: 'For complex & thinking tasks',
  ),
  FlowModelOption(
    id: 'haiku-4-5',
    label: 'Haiku 4.5',
    description: 'Fastest for quick answers',
  ),
];

const List<FlowModelOption> _moreModels = [
  FlowModelOption(id: 'sonnet-4-5', label: 'Sonnet 4.5'),
  FlowModelOption(id: 'opus-4-1', label: 'Opus 4.1'),
  FlowModelOption(id: 'legacy', label: 'Legacy', enabled: false),
];

const List<FlowEffortOption> _efforts = [
  FlowEffortOption(
    id: 'low',
    label: 'Low',
    description: 'Quickest replies. Simple answers',
  ),
  FlowEffortOption(
    id: 'medium',
    label: 'Medium',
    description: 'Light & casual tasks',
  ),
  FlowEffortOption(
    id: 'high',
    label: 'High',
    description: 'Balance between speed & complexity',
  ),
  FlowEffortOption(
    id: 'max',
    label: 'Max',
    description: 'Complex, extensive tasks',
  ),
];

/// Demo for [FlowModelSelector].
class ModelSelectorPage extends StatelessWidget {
  const ModelSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Model selector',
      className: 'FlowModelSelector',
      description:
          'A compact model picker for the composer\'s trailing slot: models, '
          'an Effort section, and an overflow behind More models. Picking '
          'anything applies immediately and closes the menu. Presentation '
          'follows the platform — an anchored menu here, a bottom sheet on '
          'phones: toggle the gallery\'s mobile view to see it.',
      children: [DemoPreview(preview: _SelectorDemo(), code: _selectorSnippet)],
    );
  }
}

class _SelectorDemo extends StatefulWidget {
  const _SelectorDemo();

  @override
  State<_SelectorDemo> createState() => _SelectorDemoState();
}

class _SelectorDemoState extends State<_SelectorDemo> {
  String _selectedId = 'fable-5';
  String _effortId = 'medium';

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowModelSelector(
          tooltip: 'Choose model',
          // Left on the `auto` default: the gallery's phone frame reports
          // a mobile platform, so the same widget anchors a menu out here
          // and presents a sheet in there.
          sheetTitle: 'Select model',
          models: _models,
          moreModels: _moreModels,
          selectedId: _selectedId,
          onSelected: (id) => setState(() => _selectedId = id),
          efforts: _efforts,
          selectedEffortId: _effortId,
          onEffortSelected: (id) => setState(() => _effortId = id),
        ),
        SizedBox(height: 16),
        Text(
          'Selected: $_selectedId · $_effortId',
          style: typography.bodySmall.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
