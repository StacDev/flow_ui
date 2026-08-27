import 'package:material_ui/material_ui.dart';

import 'demos/add_to_chat_demo.dart';
import 'demos/attachments_demo.dart';
import 'demos/code_block_demo.dart';
import 'demos/composer_demo.dart';
import 'demos/error_state_demo.dart';
import 'demos/full_chat_demo.dart';
import 'demos/greeting_demo.dart';
import 'demos/markdown_demo.dart';
import 'demos/message_actions_demo.dart';
import 'demos/message_demo.dart';
import 'demos/model_selector_demo.dart';
import 'demos/pill_demo.dart';
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
    PlaygroundItem.fullChat => FullChatDemo(key: key, variant: variant),
    PlaygroundItem.composer => ComposerDemo(key: key, variant: variant),
    PlaygroundItem.modalSelector => ModelSelectorDemo(key: key),
    PlaygroundItem.message => MessageDemo(key: key, variant: variant),
    PlaygroundItem.streamingMessage => StreamingMessageDemo(
      key: key,
      variant: variant,
    ),
    PlaygroundItem.codeBlock => CodeBlockDemo(key: key, variant: variant),
    PlaygroundItem.markdown => MarkdownDemo(key: key, variant: variant),
    PlaygroundItem.errorState => ErrorStateDemo(key: key, variant: variant),
    PlaygroundItem.addToChat => AddToChatDemo(key: key),
    PlaygroundItem.pill => PillDemo(key: key, variant: variant),
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
    PlaygroundItem.fullChat => const [
      ('default', 'Default'),
      ('drop', 'Drop files'),
    ],
    PlaygroundItem.composer => const [
      ('default', 'Default'),
      ('streaming', 'Streaming'),
    ],
    PlaygroundItem.message => const [
      ('pair', 'Conversation'),
      ('ai', 'Assistant'),
      ('user', 'User'),
      ('image', 'With image'),
    ],
    PlaygroundItem.streamingMessage => const [
      ('animated', 'Animated'),
      ('static', 'Static'),
      ('image', 'Image'),
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
    PlaygroundItem.markdown => const [
      ('document', 'Document'),
      ('streaming', 'Streaming'),
      ('tables', 'Tables'),
      ('links', 'Links'),
    ],
    PlaygroundItem.errorState => const [
      ('card', 'Card'),
      ('minimal', 'Minimal'),
      ('thread', 'Failed turn'),
    ],
    PlaygroundItem.pill => const [
      ('default', 'Default'),
      ('icon', 'Icon only'),
      ('static', 'No remove'),
      ('composer', 'In composer'),
    ],
    PlaygroundItem.attachments => const [
      ('composer', 'In composer'),
      ('tiles', 'Tiles only'),
    ],
    PlaygroundItem.thread => const [
      ('default', 'Default'),
      ('streaming', 'Streaming'),
      ('short', 'Short'),
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
/// demo's plumbing. [variant] is the stage's active pill, so the code
/// follows what the demo is showing.
String snippetFor(PlaygroundItem item, {String? variant}) {
  return switch (item) {
    PlaygroundItem.fullChat => _fullChatSnippet(variant),
    PlaygroundItem.composer => composerSnippet(variant),
    PlaygroundItem.modalSelector => modelSelectorSnippet,
    PlaygroundItem.message => messageSnippet(variant),
    PlaygroundItem.streamingMessage => streamingMessageSnippet(variant),
    PlaygroundItem.codeBlock => codeBlockSnippet(variant),
    PlaygroundItem.markdown => markdownSnippet(variant),
    PlaygroundItem.errorState => errorStateSnippet(variant),
    PlaygroundItem.addToChat => addToChatSnippet,
    PlaygroundItem.pill => pillSnippet(variant),
    PlaygroundItem.attachments => attachmentsSnippet(variant),
    PlaygroundItem.thread => threadSnippet(variant),
    PlaygroundItem.messageActions => messageActionsSnippet,
    PlaygroundItem.streamingText => streamingTextSnippet(variant),
    PlaygroundItem.shimmerText => shimmerTextSnippet(variant),
    PlaygroundItem.thinkingIndicator => thinkingIndicatorSnippet(variant),
    PlaygroundItem.suggestions => suggestionsSnippet(variant),
    PlaygroundItem.greeting => greetingSnippet(variant),
  };
}

String _fullChatSnippet(String? variant) => switch (variant) {
  'drop' => _fullChatDropSnippet,
  _ => _fullChatDefaultSnippet,
};

const String _fullChatDropSnippet = '''
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
  dropLabel: 'Drop images to attach',
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

const String _fullChatDefaultSnippet = '''
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
    // The attach button opens the platform's dialog and hands back
    // decoded attachments; the host holds them.
    onAttachmentsPicked: (picked) =>
        setState(() => pending.addAll(picked)),
    attachTooltip: 'Attach images',
    attachments: pending,
    onRemoveAttachment: removePending,
    leadingActions: [
      FlowMenu(
        icon: PhosphorIconsRegular.plus,
        sheetTitle: 'Add to Chat',
        entries: [...],
        onSelected: toggleTool,
      ),
      if (researchOn)
        FlowPill(
          icon: PhosphorIconsRegular.graduationCap,
          label: 'Research',
          removeTooltip: 'Turn off Research',
          onRemove: () => setResearch(false),
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
