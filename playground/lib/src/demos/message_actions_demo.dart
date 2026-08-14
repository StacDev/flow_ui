import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

const String messageActionsSnippet = '''
FlowMessageActions(
  actions: [
    FlowMessageAction.copy(tooltip: 'Copy', onPressed: copy),
    FlowMessageAction.thumbUp(
      tooltip: 'Good response',
      selected: liked, // selected actions render filled
      onPressed: like,
    ),
    FlowMessageAction.thumbDown(
      tooltip: 'Bad response',
      selected: disliked,
      onPressed: dislike,
    ),
    FlowMessageAction.regenerate(tooltip: 'Retry', onPressed: retry),
  ],
)''';

/// The actions strip on its own — every button live, thumbs mutually
/// exclusive, the way it sits under an assistant message.
class MessageActionsDemo extends StatefulWidget {
  const MessageActionsDemo({super.key});

  @override
  State<MessageActionsDemo> createState() => _MessageActionsDemoState();
}

class _MessageActionsDemoState extends State<MessageActionsDemo> {
  bool _liked = false;
  bool _disliked = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlowMessageActions(
        actions: [
          FlowMessageAction.copy(tooltip: 'Copy', onPressed: () {}),
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
          FlowMessageAction.regenerate(tooltip: 'Retry', onPressed: () {}),
        ],
      ),
    );
  }
}
