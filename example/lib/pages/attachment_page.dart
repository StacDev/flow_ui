import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _rowSnippet = '''
FlowAttachmentGroup(
  // The default: one row that scrolls, no scrollbar.
  attachments: [
    for (final picked in pending)
      FlowAttachment(
        id: picked.id,
        thumbnail: FileImage(picked.file),
        label: picked.name,
      ),
  ],
  onRemove: (id) => detach(id),
  removeTooltip: 'Remove attachment',
)''';

const String _wrapSnippet = '''
FlowAttachmentGroup(
  layout: FlowAttachmentLayout.wrap,
  size: 80,
  // No onRemove → read-only. Tapping still opens the preview: pass onTap
  // only to replace it, and call showFlowAttachmentPreview yourself to
  // keep it alongside your own handling.
  attachments: [...],
)''';

const String _messageSnippet = '''
FlowMessage(
  FlowMessageData(
    id: 'm1',
    role: FlowMessageRole.user,
    parts: [
      FlowAttachmentPart([
        FlowAttachment(id: 'a', thumbnail: NetworkImage(url)),
      ]),
      FlowTextPart('What is the peak on the left?'),
    ],
  ),
  // Nothing to wire: tapping a sent attachment opens the preview.
)''';

const String _composerSnippet = '''
FlowComposer(
  attachments: attachments,
  onRemoveAttachment: (id) => setState(
    () => attachments = attachments.where((a) => a.id != id).toList(),
  ),
  removeAttachmentTooltip: 'Remove attachment',
  onSend: send,
  leadingActions: [
    FlowAddMenu(options: addOptions, onSelected: pickAttachment),
  ],
)''';

/// Demo for [FlowAttachment] and [FlowAttachmentGroup].
class AttachmentPage extends StatelessWidget {
  const AttachmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Attachments',
      className: 'FlowAttachment & FlowAttachmentGroup',
      description:
          'Image thumbnails for the composer and for sent messages. Tapping '
          'one opens a full-screen preview you can zoom and page through. '
          'The remove button fades in on hover and stays visible on touch; '
          'without an onRemove callback the tiles are read-only.',
      children: [
        SectionHeader('Scrolling row'),
        DemoPreview(
          preview: _RowDemo(),
          code: _rowSnippet,
          alignment: Alignment.centerLeft,
        ),
        SectionHeader('Wrap, read-only'),
        DemoPreview(
          preview: _WrapDemo(),
          code: _wrapSnippet,
          alignment: Alignment.centerLeft,
        ),
        SectionHeader('In a message'),
        DemoPreview(
          preview: _MessageDemo(),
          code: _messageSnippet,
          minHeight: 200,
        ),
        SectionHeader('In a composer'),
        DemoPreview(
          preview: _ComposerDemo(),
          code: _composerSnippet,
          minHeight: 240,
        ),
      ],
    );
  }
}

/// The gallery's stand-in photos, generated rather than photographed.
const List<({String id, String asset, String label})> _samples = [
  (id: 'dusk', asset: 'assets/dusk.png', label: 'dusk-ridge.png'),
  (id: 'tide', asset: 'assets/tide.png', label: 'tide-bands.png'),
  (id: 'ember', asset: 'assets/ember.png', label: 'ember-glow.png'),
  (id: 'fern', asset: 'assets/fern.png', label: 'fern-valley.png'),
];

List<FlowAttachment> _attachments([int count = 4]) => [
  for (final sample in _samples.take(count))
    FlowAttachment(
      id: sample.id,
      thumbnail: AssetImage(sample.asset),
      label: sample.label,
    ),
];

class _RowDemo extends StatefulWidget {
  const _RowDemo();

  @override
  State<_RowDemo> createState() => _RowDemoState();
}

class _RowDemoState extends State<_RowDemo> {
  List<FlowAttachment> _items = _attachments();

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return TextButton(
        onPressed: () => setState(() => _items = _attachments()),
        child: const Text('Restore attachments'),
      );
    }
    return FlowAttachmentGroup(
      attachments: _items,
      removeTooltip: 'Remove attachment',
      previewCloseTooltip: 'Close preview',
      onRemove: (id) =>
          setState(() => _items = _items.where((a) => a.id != id).toList()),
    );
  }
}

class _WrapDemo extends StatelessWidget {
  const _WrapDemo();

  @override
  Widget build(BuildContext context) {
    return FlowAttachmentGroup(
      attachments: _attachments(),
      layout: FlowAttachmentLayout.wrap,
      size: 80,
      previewCloseTooltip: 'Close preview',
    );
  }
}

class _MessageDemo extends StatelessWidget {
  const _MessageDemo();

  @override
  Widget build(BuildContext context) {
    return FlowMessage(
      FlowMessageData(
        id: 'm1',
        role: FlowMessageRole.user,
        parts: [
          FlowAttachmentPart(_attachments(3)),
          const FlowTextPart('What is the peak on the left?'),
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
  List<FlowAttachment> _items = _attachments(2);

  void _add() {
    // Cycles rather than counting up, so removing every attachment doesn't
    // leave the demo with nothing to add back.
    final sample = _samples.firstWhere(
      (s) => !_items.any((a) => a.id == s.id),
      orElse: () => _samples.first,
    );
    if (_items.any((a) => a.id == sample.id)) return;
    setState(() {
      _items = [
        ..._items,
        FlowAttachment(
          id: sample.id,
          thumbnail: AssetImage(sample.asset),
          label: sample.label,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlowComposer(
      placeholder: 'Describe these images…',
      attachments: _items,
      removeAttachmentTooltip: 'Remove attachment',
      onRemoveAttachment: (id) =>
          setState(() => _items = _items.where((a) => a.id != id).toList()),
      onSend: (text) => _notify(context, 'Sent with ${_items.length} images'),
      leadingActions: [
        FlowAddMenu(
          tooltip: 'Add to chat',
          options: const [
            FlowAddOption(
              id: 'photos',
              icon: Icons.image_outlined,
              label: 'Add a photo',
            ),
          ],
          onSelected: (_) => _add(),
        ),
      ],
    );
  }
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        width: 280,
      ),
    );
}
