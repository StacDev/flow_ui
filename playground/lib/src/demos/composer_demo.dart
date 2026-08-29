import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_content.dart';
import 'rejection_notice.dart';

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
  // Drag-and-drop scoped to the card, which lights up while a file is
  // over it. FlowChatView.onAttachmentsDropped is the same thing over
  // the whole surface; wire either, or both — the innermost wins.
  onAttachmentsDropped: (dropped) => setState(() => pending.addAll(dropped)),
  // And Ctrl+V / Cmd+V, while the field has focus.
  onAttachmentsPasted: (pasted) => setState(() => pending.addAll(pasted)),
  attachmentOptions: const FlowAttachmentOptions(
    accept: [FlowAttachmentTypeGroup.images],
    maxFileSize: 10 * 1024 * 1024,
  ),
  onAttachmentRejected: (name, reason) => showRejection(name, reason),
  attachments: pending,
  onRemoveAttachment: removePending,
  leadingActions: [
    FlowMenu(
      icon: PhosphorIconsRegular.plus,
      sheetTitle: 'Add to Chat',
      entries: [
        FlowMenuOption(id: 'files', label: 'Add Files or Photos'),
        ...,
      ],
      // 'Add Files or Photos' opens the package's own dialog and hands
      // back decoded attachments; the picker returns empty when
      // dismissed and never throws. (onAttachmentsPicked renders a
      // built-in attach button that does the same.)
      onSelected: (id) => id == 'files' ? pickFiles() : toggleTool(id),
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
)

Future<void> pickFiles() async {
  final picked = await showFlowAttachmentPicker(
    options: attachmentOptions,
    onRejected: showRejection,
  );
  setState(() => pending.addAll(picked));
}''';

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
  final List<FlowAttachment> _attachments = [];
  String? _rejection;

  static const FlowAttachmentOptions _attachmentOptions = FlowAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add(List<FlowAttachment> attachments) {
    setState(() {
      _rejection = null;
      _attachments.addAll(attachments);
    });
  }

  void _reject(String name, FlowAttachmentRejection reason) {
    final why = switch (reason) {
      FlowAttachmentRejection.tooLarge => 'is larger than 10 MB',
      FlowAttachmentRejection.unsupportedType => 'is not an image',
      FlowAttachmentRejection.unreadable => 'could not be read',
    };
    setState(() => _rejection = '$name $why');
  }

  /// The "+" menu's 'Add Files or Photos': the package's dialog, opened
  /// synchronously from the tap so the web keeps its user activation.
  Future<void> _pickFiles() async {
    final picked = await showFlowAttachmentPicker(
      options: _attachmentOptions,
      onRejected: _reject,
    );
    if (!mounted || picked.isEmpty) return;
    _add(picked);
  }

  @override
  Widget build(BuildContext context) {
    final rejection = _rejection;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rejection != null) ...[
              RejectionNotice(
                message: rejection,
                onDismissed: () => setState(() => _rejection = null),
              ),
              const SizedBox(height: 8),
            ],
            FlowComposer(
              controller: _input,
              placeholder: 'How can I help you today?',
              isStreaming: widget.variant == 'streaming',
              onSend: (_) {},
              onStop: () {},
              // Drop scoped to the card: drag an image anywhere else on the
              // stage and nothing happens — over the composer it lights up.
              onAttachmentsDropped: _add,
              // Focus the field and paste a screenshot.
              onAttachmentsPasted: _add,
              attachmentOptions: _attachmentOptions,
              onAttachmentRejected: _reject,
              attachments: List.of(_attachments),
              onRemoveAttachment: (id) =>
                  setState(() => _attachments.removeWhere((a) => a.id == id)),
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
                  // 'Add Files or Photos' opens the real dialog.
                  onSelected: (id) {
                    if (id == 'files') unawaited(_pickFiles());
                  },
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
          ],
        ),
      ),
    );
  }
}
