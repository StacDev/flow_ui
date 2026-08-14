import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'demo_content.dart';

const String modelSelectorSnippet = '''
FlowModelSelector(
  models: const [
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
  selectedId: modelId,
  onSelected: setModel,
  efforts: efforts,
  selectedEffortId: effortId,
  onEffortSelected: setEffort,
  moreModels: olderModels,
  // Anchored menu on desktop, bottom sheet on phones.
  presentation: FlowMenuPresentation.auto,
)''';

/// The model selector trigger, live: opens the roster with the Effort and
/// More models submenus — anchored on the web stage, a bottom sheet inside
/// the phone.
class ModelSelectorDemo extends StatefulWidget {
  const ModelSelectorDemo({super.key});

  @override
  State<ModelSelectorDemo> createState() => _ModelSelectorDemoState();
}

class _ModelSelectorDemoState extends State<ModelSelectorDemo> {
  String _modelId = 'opus-5-1';
  String _effortId = 'extra';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlowModelSelector(
        tooltip: 'Choose model',
        sheetTitle: 'Select model',
        models: demoModels,
        selectedId: _modelId,
        onSelected: (id) => setState(() => _modelId = id),
        efforts: demoEfforts,
        selectedEffortId: _effortId,
        onEffortSelected: (id) => setState(() => _effortId = id),
        moreModels: demoMoreModels,
      ),
    );
  }
}
