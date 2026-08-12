import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _rowSnippet = '''
FlowMessageActions(
  actions: [
    FlowMessageAction.copy(tooltip: 'Copy', onPressed: () {}),
    FlowMessageAction.regenerate(tooltip: 'Regenerate', onPressed: () {}),
    FlowMessageAction.edit(tooltip: 'Edit'), // no onPressed → disabled
    FlowMessageAction.thumbUp(
      tooltip: 'Good response',
      selected: liked,
      onPressed: toggleLike,
    ),
    FlowMessageAction.thumbDown(
      tooltip: 'Bad response',
      selected: disliked,
      onPressed: toggleDislike,
    ),
  ],
)''';

const String _footerSnippet = '''
FlowMessage(
  message,
  footer: FlowMessageActions(
    actions: [
      FlowMessageAction.copy(tooltip: 'Copy', onPressed: () {}),
      FlowMessageAction.regenerate(tooltip: 'Regenerate', onPressed: () {}),
    ],
  ),
)''';

/// Demo for [FlowMessageActions].
class MessageActionsPage extends StatelessWidget {
  const MessageActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Message actions',
      className: 'FlowMessageActions',
      description:
          'The action row under a message — copy, regenerate, edit, and '
          'feedback. The thumbs toggle and exclude each other; disabled '
          'actions render muted.',
      children: [
        SectionHeader('Action row'),
        DemoPreview(preview: _ActionsRowDemo(), code: _rowSnippet),
        SectionHeader('Under a message'),
        DemoPreview(preview: _MessageFooterDemo(), code: _footerSnippet),
      ],
    );
  }
}

class _ActionsRowDemo extends StatefulWidget {
  const _ActionsRowDemo();

  @override
  State<_ActionsRowDemo> createState() => _ActionsRowDemoState();
}

class _ActionsRowDemoState extends State<_ActionsRowDemo> {
  bool _liked = false;
  bool _disliked = false;

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: 220,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FlowMessageActions(
      actions: [
        FlowMessageAction.copy(
          tooltip: 'Copy',
          onPressed: () => _notify(context, 'Copied'),
        ),
        FlowMessageAction.regenerate(
          tooltip: 'Regenerate',
          onPressed: () => _notify(context, 'Regenerating…'),
        ),
        const FlowMessageAction.edit(tooltip: 'Edit (disabled)'),
        FlowMessageAction.thumbUp(
          tooltip: 'Good response',
          selected: _liked,
          onPressed: () => setState(() {
            _liked = !_liked;
            if (_liked) _disliked = false;
          }),
        ),
        FlowMessageAction.thumbDown(
          tooltip: 'Bad response',
          selected: _disliked,
          onPressed: () => setState(() {
            _disliked = !_disliked;
            if (_disliked) _liked = false;
          }),
        ),
      ],
    );
  }
}

class _MessageFooterDemo extends StatelessWidget {
  const _MessageFooterDemo();

  @override
  Widget build(BuildContext context) {
    return FlowMessage(
      FlowMessageData.text(
        id: 'a1',
        role: FlowMessageRole.assistant,
        text:
            'Here is the summary you asked for — three sections, each with '
            'the key numbers pulled from the report.',
      ),
      footer: FlowMessageActions(
        actions: [
          FlowMessageAction.copy(tooltip: 'Copy', onPressed: () {}),
          FlowMessageAction.regenerate(tooltip: 'Regenerate', onPressed: () {}),
        ],
      ),
    );
  }
}
