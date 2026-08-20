import 'package:material_ui/material_ui.dart';

import 'demos/add_to_chat_demo.dart';
import 'demos/attachments_demo.dart';
import 'demos/code_block_demo.dart';
import 'demos/composer_demo.dart';
import 'demos/error_state_demo.dart';
import 'demos/full_chat_demo.dart';
import 'demos/greeting_demo.dart';
import 'demos/message_actions_demo.dart';
import 'demos/message_demo.dart';
import 'demos/model_selector_demo.dart';
import 'demos/shimmer_text_demo.dart';
import 'demos/streaming_message_demo.dart';
import 'demos/streaming_text_demo.dart';
import 'demos/suggestions_demo.dart';
import 'demos/thinking_indicator_demo.dart';
import 'demos/thread_demo.dart';
import 'playground_item.dart';

/// The stage's demo for [item]. Keyed on the variant so switching pills
/// resets the demo's local state (removed attachments come back, and so
/// on).
Widget demoFor(PlaygroundItem item, {String? variant}) {
  final key = ValueKey('${item.name}-$variant');
  return switch (item) {
    PlaygroundItem.fullChat => FullChatDemo(key: key),
    PlaygroundItem.composer => ComposerDemo(key: key, variant: variant),
    PlaygroundItem.modalSelector => ModelSelectorDemo(key: key),
    PlaygroundItem.message => MessageDemo(key: key, variant: variant),
    PlaygroundItem.streamingMessage => StreamingMessageDemo(
      key: key,
      variant: variant,
    ),
    PlaygroundItem.codeBlock => CodeBlockDemo(key: key, variant: variant),
    PlaygroundItem.errorState => ErrorStateDemo(key: key, variant: variant),
    PlaygroundItem.addToChat => AddToChatDemo(key: key),
    PlaygroundItem.attachments => AttachmentsDemo(key: key, variant: variant),
    PlaygroundItem.thread => ThreadDemo(key: key, variant: variant),
    PlaygroundItem.messageActions => MessageActionsDemo(key: key),
    PlaygroundItem.streamingText => StreamingTextDemo(
      key: key,
      variant: variant,
    ),
    PlaygroundItem.shimmerText => ShimmerTextDemo(key: key, variant: variant),
    PlaygroundItem.thinkingIndicator => ThinkingIndicatorDemo(
      key: key,
      variant: variant,
    ),
    PlaygroundItem.suggestions => SuggestionsDemo(key: key, variant: variant),
    PlaygroundItem.greeting => GreetingDemo(key: key, variant: variant),
  };
}

/// The floating pill switcher's options for [item] — empty when the item
/// has a single form. The first entry is the default.
List<(String, String)> variantsFor(PlaygroundItem item) {
  return switch (item) {
    PlaygroundItem.composer => const [
      ('default', 'Default'),
      ('streaming', 'Streaming'),
    ],
    PlaygroundItem.message => const [
      ('pair', 'Conversation'),
      ('ai', 'Assistant'),
      ('user', 'User'),
    ],
    PlaygroundItem.streamingMessage => const [
      ('animated', 'Animated'),
      ('static', 'Static'),
    ],
    PlaygroundItem.codeBlock => const [
      ('dart', 'Dart'),
      ('json', 'JSON'),
      ('yaml', 'YAML'),
      ('html', 'HTML'),
      ('css', 'CSS'),
      ('sql', 'SQL'),
      ('plain', 'Plain'),
      ('streaming', 'Streaming'),
    ],
    PlaygroundItem.errorState => const [
      ('card', 'Card'),
      ('minimal', 'Minimal'),
      ('thread', 'Failed turn'),
    ],
    PlaygroundItem.attachments => const [
      ('composer', 'In composer'),
      ('tiles', 'Tiles only'),
    ],
    PlaygroundItem.thread => const [
      ('default', 'Default'),
      ('streaming', 'Streaming'),
    ],
    PlaygroundItem.streamingText => const [
      ('animated', 'Animated'),
      ('instant', 'Instant'),
    ],
    PlaygroundItem.shimmerText => const [
      ('active', 'Active'),
      ('settled', 'Settled'),
    ],
    PlaygroundItem.thinkingIndicator => const [
      ('active', 'Active'),
      ('settled', 'Settled'),
    ],
    PlaygroundItem.suggestions => const [
      ('column', 'Column'),
      ('scroll', 'Scroll'),
      ('wrap', 'Wrap'),
    ],
    PlaygroundItem.greeting => const [
      ('icon', 'With icon'),
      ('text', 'Text only'),
    ],
    _ => const [],
  };
}

/// Whether the demo takes the whole stage pane (a full surface) rather
/// than sitting as an object on the canvas.
bool demoFillsStage(PlaygroundItem item) => item == PlaygroundItem.fullChat;

/// The code panel's snippet for [item] — the real flow_ui usage, not the
/// demo's plumbing.
String snippetFor(PlaygroundItem item) {
  return switch (item) {
    PlaygroundItem.fullChat => _fullChatSnippet,
    PlaygroundItem.composer => composerSnippet,
    PlaygroundItem.modalSelector => modelSelectorSnippet,
    PlaygroundItem.message => messageSnippet,
    PlaygroundItem.streamingMessage => streamingMessageSnippet,
    PlaygroundItem.codeBlock => codeBlockSnippet,
    PlaygroundItem.errorState => errorStateSnippet,
    PlaygroundItem.addToChat => addToChatSnippet,
    PlaygroundItem.attachments => attachmentsSnippet,
    PlaygroundItem.thread => threadSnippet,
    PlaygroundItem.messageActions => messageActionsSnippet,
    PlaygroundItem.streamingText => streamingTextSnippet,
    PlaygroundItem.shimmerText => shimmerTextSnippet,
    PlaygroundItem.thinkingIndicator => thinkingIndicatorSnippet,
    PlaygroundItem.suggestions => suggestionsSnippet,
    PlaygroundItem.greeting => greetingSnippet,
  };
}

const String _fullChatSnippet = '''
FlowChatView(
  empty: messages.isEmpty,
  greeting: const FlowGreeting(
    icon: PhosphorIconsRegular.sunHorizon,
    text: 'Good Afternoon, Divyanshu',
  ),
  suggestions: FlowSuggestionGroup(
    layout: FlowSuggestionLayout.column,
    suggestions: [
      for (final starter in starters)
        FlowSuggestion(
          label: starter.prompt,
          icon: starter.icon,
          onTap: () => input.text = starter.prompt,
        ),
    ],
  ),
  thread: FlowThread(
    messages: messages,
    controller: scroll,
    thinkingLabel: 'thinking..',
  ),
  threadController: scroll,
  jumpToLatestTooltip: 'Jump to latest',
  composer: FlowComposer(
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
        models: [...],
        selectedId: modelId,
        onSelected: setModel,
        efforts: [...],
        selectedEffortId: effortId,
        onEffortSelected: setEffort,
      ),
    ],
  ),
)''';
