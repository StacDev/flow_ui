import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

const String messageSnippet = '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    FlowMessage(
      FlowMessageData.text(
        id: 'u1',
        role: FlowMessageRole.user,
        text: 'Can you tell me more about what you can do?',
      ),
    ),
    const SizedBox(height: 26),
    FlowMessage(
      const FlowMessageData(
        id: 'a1',
        role: FlowMessageRole.assistant,
        parts: [
          // FlowCustomPart is the host-content seam: the builder below
          // renders this one as the heading.
          FlowCustomPart(type: 'heading', data: 'Hello! I am AI chat :)'),
          FlowTextPart('I can assist you with most tasks across...'),
        ],
      ),
      customPartBuilder: (context, message, part) =>
          part.type == 'heading' ? Heading(part.data as String) : null,
      footer: FlowMessageActions(
        actions: [
          FlowMessageAction.copy(onPressed: copy),
          FlowMessageAction.thumbUp(selected: liked, onPressed: like),
          FlowMessageAction.thumbDown(selected: disliked, onPressed: dislike),
          FlowMessageAction.regenerate(onPressed: retry),
        ],
      ),
    ),
  ],
)''';

const String _userText = 'Can you tell me more about what you can do?';
const String _heading = 'Hello! I am AI chat :)';
const String _body =
    'I can assist you with most tasks across this app — changing your name, '
    'booking a hotel, or getting a cab. What can I do for you today? If you '
    'need anything else, just type it out.';

/// The message pair from the design: ink-wash user bubble, plain assistant
/// message with a heading (rendered through the custom-part seam) and the
/// actions row. Variants show the conversation or either side alone.
class MessageDemo extends StatefulWidget {
  const MessageDemo({super.key, this.variant});

  final String? variant;

  @override
  State<MessageDemo> createState() => _MessageDemoState();
}

class _MessageDemoState extends State<MessageDemo> {
  bool _liked = false;
  bool _disliked = false;

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant ?? 'pair';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (variant != 'ai')
              FlowMessage(
                FlowMessageData.text(
                  id: 'u1',
                  role: FlowMessageRole.user,
                  text: _userText,
                ),
              ),
            if (variant == 'pair') const SizedBox(height: 26),
            if (variant != 'user')
              FlowMessage(
                const FlowMessageData(
                  id: 'a1',
                  role: FlowMessageRole.assistant,
                  parts: [
                    FlowCustomPart(type: 'heading', data: _heading),
                    FlowTextPart(_body),
                  ],
                ),
                customPartBuilder: (context, message, part) {
                  if (part.type != 'heading') return null;
                  return Text(
                    part.data as String,
                    style: context.flowTypography.titleMedium.copyWith(
                      color: context.flowColors.onSurface,
                    ),
                  );
                },
                footer: FlowMessageActions(
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
                    FlowMessageAction.regenerate(
                      tooltip: 'Retry',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
