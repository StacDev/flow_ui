import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_content.dart';

const String attachmentsSnippet = '''
FlowComposer(
  controller: input,
  attachments: [
    // No thumbnail: the tile draws the wash with the kind pill.
    FlowAttachment(id: 'spec', kind: 'PDF', label: 'sensor-spec.pdf'),
    FlowAttachment(id: 'photo', kind: 'JPG', label: 'prototype.jpg'),
  ],
  onRemoveAttachment: remove,
  removeAttachmentTooltip: 'Remove',
  onSend: send,
)

// Or the strip on its own:
FlowAttachmentGroup(
  attachments: attachments,
  onRemove: remove,
)''';

const List<FlowAttachment> _seed = [
  FlowAttachment(id: 'spec', kind: 'PDF', label: 'sensor-spec.pdf'),
  FlowAttachment(id: 'photo', kind: 'JPG', label: 'prototype.jpg'),
];

/// Attachments as the design stages them — kind-pill tiles in the
/// composer, prefilled with the mock's message, each removable. The
/// Tiles-only variant shows the standalone [FlowAttachmentGroup].
class AttachmentsDemo extends StatefulWidget {
  const AttachmentsDemo({super.key, this.variant});

  final String? variant;

  @override
  State<AttachmentsDemo> createState() => _AttachmentsDemoState();
}

class _AttachmentsDemoState extends State<AttachmentsDemo> {
  late final TextEditingController _input = TextEditingController(
    text: 'Make the best sensor out there for me. Be the best',
  );
  List<FlowAttachment> _attachments = _seed;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _remove(String id) {
    setState(() {
      _attachments = [..._attachments.where((a) => a.id != id)];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'tiles') {
      return Center(
        child: FlowAttachmentGroup(
          attachments: _attachments,
          onRemove: _remove,
          removeTooltip: 'Remove',
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FlowComposer(
          controller: _input,
          placeholder: 'How can I help you today?',
          attachments: _attachments,
          onRemoveAttachment: _remove,
          removeAttachmentTooltip: 'Remove',
          onSend: (_) {},
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
              ],
              onSelected: (_) => setState(() => _attachments = _seed),
            ),
          ],
          trailingActions: [
            FlowModelSelector(
              tooltip: 'Choose model',
              sheetTitle: 'Select model',
              models: demoModels,
              selectedId: 'opus-5-1',
              onSelected: (_) {},
              efforts: demoEfforts,
              selectedEffortId: 'extra',
              onEffortSelected: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}
