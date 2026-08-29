import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_content.dart';
import 'rejection_notice.dart';

String attachmentsSnippet([String? variant]) => switch (variant) {
  'tiles' => _tilesSnip,
  'drop' => _dropSnip,
  _ => _composerSnip,
};

const String _composerSnip = '''
FlowComposer(
  controller: input,
  attachments: [
    // No thumbnail: the tile draws the wash with the kind pill. Picked
    // images carry theirs too — 'JPG' over the corner of the picture.
    FlowAttachment(id: 'spec', kind: 'PDF', label: 'sensor-spec.pdf'),
    FlowAttachment(id: 'photo', kind: 'JPG', label: 'prototype.jpg'),
  ],
  onRemoveAttachment: remove,
  removeAttachmentTooltip: 'Remove',
  onSend: send,
  leadingActions: [
    FlowMenu(
      icon: PhosphorIconsRegular.plus,
      sheetTitle: 'Add to Chat',
      entries: [FlowMenuOption(id: 'files', label: 'Add Files or Photos')],
      // The package's own dialog, from the host's menu.
      onSelected: (id) {
        if (id == 'files') pickFiles();
      },
    ),
  ],
)

Future<void> pickFiles() async {
  final picked = await showFlowAttachmentPicker(onRejected: showRejection);
  setState(() => attachments.addAll(picked));
}''';

const String _dropSnip = '''
// onAttachmentsDropped turns on the surface's own drag-and-drop: it
// raises the treatment while a file is over the page and comes back
// with what landed, read and decoded. Web only — the SDK implements OS
// file drop nowhere else — so desktop hosts bring their own detection
// and flip dropActive, which stays writable for exactly that.
FlowChatView(
  onAttachmentsDropped: (dropped) =>
      setState(() => pending.addAll(dropped)),
  onAttachmentRejected: showRejection,
  attachmentOptions: const FlowAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  ),
  dropLabel: 'Drop files to add to chat',
  // An override, not a switch: the treatment is up while this is true
  // or a real drag is over the surface.
  dropActive: dragHovering,
  thread: FlowThread(messages: messages),
  composer: FlowComposer(
    onSend: send,
    attachments: pending,
    onRemoveAttachment: removePending,
  ),
)''';

const String _tilesSnip = '''
// The strip on its own, outside a composer.
FlowAttachmentGroup(
  attachments: attachments,
  onRemove: remove,
)''';

const List<FlowAttachment> _seed = [
  FlowAttachment(id: 'spec', kind: 'PDF', label: 'sensor-spec.pdf'),
  FlowAttachment(id: 'photo', kind: 'JPG', label: 'prototype.jpg'),
];

/// Attachments as the design stages them — kind-pill tiles in the
/// composer, prefilled with the mock's message, each removable, with the
/// "+" menu opening the real dialog. The Tiles-only variant shows the
/// standalone [FlowAttachmentGroup]; Drop files pins the chat surface's
/// drag-and-drop treatment so it can be seen without a real drag.
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
  String? _rejection;

  static const FlowAttachmentOptions _attachmentOptions = FlowAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

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
    setState(() {
      _rejection = null;
      _attachments = [..._attachments, ...picked];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'drop') return const _DropDemo();
    if (widget.variant == 'tiles') {
      return Center(
        child: FlowAttachmentGroup(
          attachments: _attachments,
          onRemove: _remove,
          removeTooltip: 'Remove',
        ),
      );
    }

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
              attachments: _attachments,
              onRemoveAttachment: _remove,
              removeAttachmentTooltip: 'Remove',
              onAttachmentRejected: _reject,
              attachmentOptions: _attachmentOptions,
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
                  // The real dialog, from the menu.
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
                  selectedId: 'opus-5-1',
                  onSelected: (_) {},
                  efforts: demoEfforts,
                  selectedEffortId: 'extra',
                  onEffortSelected: (_) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The chat surface with its drop treatment pinned up, so the stage and
/// the docs embed show it without anyone holding a file over the page.
/// A real drag works too — `dropActive` is an override, not a switch.
class _DropDemo extends StatefulWidget {
  const _DropDemo();

  @override
  State<_DropDemo> createState() => _DropDemoState();
}

class _DropDemoState extends State<_DropDemo> {
  static const FlowAttachmentOptions _attachmentOptions = FlowAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

  late final TextEditingController _input = TextEditingController(
    text: 'Make the best sensor out there for me. Be the best',
  );
  List<FlowAttachment> _pending = _seed;
  String? _rejection;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add(List<FlowAttachment> attachments) {
    setState(() {
      _rejection = null;
      _pending = [..._pending, ...attachments];
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
    return FlowChatView(
      onAttachmentsDropped: _add,
      onAttachmentRejected: _reject,
      attachmentOptions: _attachmentOptions,
      dropActive: true,
      dropLabel: 'Drop files to add to chat',
      aboveComposer: rejection == null
          ? null
          : RejectionNotice(
              message: rejection,
              onDismissed: () => setState(() => _rejection = null),
            ),
      thread: const FlowThread(messages: []),
      composer: FlowComposer(
        controller: _input,
        placeholder: 'How can I help you today?',
        attachments: _pending,
        onRemoveAttachment: (id) => setState(() {
          _pending = [..._pending.where((a) => a.id != id)];
        }),
        removeAttachmentTooltip: 'Remove',
        onAttachmentsPasted: _add,
        onAttachmentRejected: _reject,
        attachmentOptions: _attachmentOptions,
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
            onSelected: (id) {
              if (id == 'files') unawaited(_pickFiles());
            },
          ),
        ],
      ),
    );
  }
}
