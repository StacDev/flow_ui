import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_content.dart';

String composerSnippet([String? variant]) => switch (variant) {
  'streaming' => _streaming,
  _ => _default,
};

const String _streaming = '''
// While a reply streams the send disc reads as stop — onStop is the
// only intent it reports; sending resumes when the stream settles.
FlowComposer(
  controller: input,
  isStreaming: true,
  onSend: send,
  onStop: stop,
)''';

const String _default = '''
FlowComposer(
  controller: input,
  placeholder: 'How can I help you today?',
  isStreaming: generating,
  onSend: send,
  onStop: stop,
  leadingActions: [
    FlowMenu(
      icon: PhosphorIconsRegular.plus,
      sheetTitle: 'Add to Chat',
      entries: [...],
      onSelected: toggleTool,
    ),
  ],
  trailingActions: [
    FlowModelSelector(
      models: models,
      selectedId: modelId,
      onSelected: setModel,
      efforts: efforts,
      selectedEffortId: effortId,
      onEffortSelected: setEffort,
    ),
  ],
)''';

/// The composer on its own: live input, the plus menu, and the model
/// selector. The Streaming variant flips [FlowComposer.isStreaming], so
/// the send disc reads as the stop control.
class ComposerDemo extends StatefulWidget {
  const ComposerDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ComposerDemo> createState() => _ComposerDemoState();
}

class _ComposerDemoState extends State<ComposerDemo> {
  final TextEditingController _input = TextEditingController();
  String _modelId = 'opus-5-1';
  String _effortId = 'extra';

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FlowComposer(
          controller: _input,
          placeholder: 'How can I help you today?',
          isStreaming: widget.variant == 'streaming',
          onSend: (_) {},
          onStop: () {},
          leadingActions: [
            FlowMenu(
              icon: PhosphorIconsRegular.plus,
              tooltip: 'Add to chat',
              sheetTitle: 'Add to Chat',
              entries: const [
                FlowMenuOption(
                  id: 'files',
                  icon: PhosphorIconsRegular.file,
                  label: 'Add Files or Photos',
                ),
                FlowMenuDivider(),
                FlowMenuOption(
                  id: 'research',
                  icon: PhosphorIconsRegular.graduationCap,
                  label: 'Research',
                ),
                FlowMenuOption(
                  id: 'web-search',
                  icon: PhosphorIconsRegular.globe,
                  label: 'Web Search',
                ),
              ],
              onSelected: (_) {},
            ),
          ],
          trailingActions: [
            FlowModelSelector(
              tooltip: 'Choose model',
              sheetTitle: 'Select model',
              models: demoModels,
              selectedId: _modelId,
              onSelected: (id) => setState(() => _modelId = id),
              efforts: demoEfforts,
              selectedEffortId: _effortId,
              onEffortSelected: (id) => setState(() => _effortId = id),
            ),
          ],
        ),
      ),
    );
  }
}
