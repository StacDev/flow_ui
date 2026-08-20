import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// The sidebar's destinations — one example plus the component demos to
/// come. Icons are Phosphor regular, the set the design is drawn in.
/// [codeFile] is the filename the code panel shows for the item, per the
/// design's snippets.
enum PlaygroundItem {
  fullChat(
    'Full Chat',
    PhosphorIconsRegular.sunHorizon,
    'full_chat_screen.dart',
    isExample: true,
  ),
  composer(
    'Composer',
    PhosphorIconsRegular.textAlignLeft,
    'flow_composer.dart',
  ),
  modalSelector(
    'Modal Selector',
    PhosphorIconsRegular.caretDown,
    'flow_model_selector.dart',
  ),
  message('Message', PhosphorIconsRegular.chat, 'flow_message.dart'),
  streamingMessage(
    'Streaming Message',
    PhosphorIconsRegular.chatCircleDots,
    'flow_streaming_message.dart',
  ),
  codeBlock('Code Block', PhosphorIconsRegular.code, 'flow_code_block.dart'),
  errorState(
    'Error State',
    PhosphorIconsRegular.warningCircle,
    'flow_error_state.dart',
  ),
  addToChat(
    'Add to Chat',
    PhosphorIconsRegular.plus,
    'flow_add_to_chat_menu.dart',
  ),
  pill('Pill', PhosphorIconsRegular.pill, 'flow_pill.dart'),
  attachments(
    'Attachments',
    PhosphorIconsRegular.paperclip,
    'flow_attachments.dart',
  ),
  thread('Thread', PhosphorIconsRegular.chats, 'flow_thread.dart'),
  messageActions(
    'Message Actions',
    PhosphorIconsRegular.thumbsUp,
    'flow_message_actions.dart',
  ),
  streamingText(
    'Streaming Text',
    PhosphorIconsRegular.textAa,
    'flow_streaming_text.dart',
  ),
  shimmerText(
    'Shimmer Text',
    PhosphorIconsRegular.sparkle,
    'flow_shimmer_text.dart',
  ),
  thinkingIndicator(
    'Thinking Indicator',
    PhosphorIconsRegular.asterisk,
    'flow_thinking_indicator.dart',
  ),
  suggestions(
    'Suggestions',
    PhosphorIconsRegular.lightbulb,
    'flow_suggestion.dart',
  ),
  greeting('Greeting', PhosphorIconsRegular.handWaving, 'flow_greeting.dart');

  const PlaygroundItem(
    this.label,
    this.icon,
    this.codeFile, {
    this.isExample = false,
  });

  final String label;
  final IconData icon;
  final String codeFile;

  /// Examples sit in their own sidebar section above the components.
  final bool isExample;
}
