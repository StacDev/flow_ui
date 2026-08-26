/// [Flow UI](https://flowui.stac.dev/) is an open-source Flutter UI library
/// to build production-grade Chat & AI assistant interfaces.
///
/// flow_ui renders state and reports intent through callbacks — it contains
/// nothing model-facing and builds only on Flutter's own first-party
/// packages.
///
/// The one thing it does reach out for is a file: the composer's attach
/// button opens the platform's own dialog, and on the web the chat
/// surface accepts drops. Both are opt-in, both hand back
/// `FlowAttachment`s for the host to hold, and neither sends anything
/// anywhere.
library;

export 'src/models/flow_attachment.dart';
export 'src/models/flow_attachment_options.dart';
export 'src/models/flow_message_data.dart';
export 'src/models/flow_message_part.dart';
export 'src/theme/flow_colors.dart';
export 'src/theme/flow_syntax_colors.dart';
export 'src/theme/flow_theme.dart';
export 'src/theme/flow_typography.dart';
export 'src/widgets/flow_attachment_group.dart';
export 'src/widgets/flow_attachment_preview.dart';
export 'src/widgets/flow_chat_view.dart';
export 'src/styles/flow_chat_view_style.dart';
export 'src/widgets/flow_code_block.dart';
export 'src/styles/flow_code_block_style.dart';
export 'src/widgets/flow_composer.dart';
export 'src/styles/flow_composer_style.dart';
export 'src/widgets/flow_drop_target.dart';
export 'src/widgets/flow_error_state.dart';
export 'src/styles/flow_error_state_style.dart';
export 'src/widgets/flow_greeting.dart';
export 'src/widgets/flow_markdown.dart';
export 'src/styles/flow_markdown_style.dart';
export 'src/widgets/flow_menu.dart';
export 'src/styles/flow_menu_style.dart';
export 'src/widgets/flow_message.dart';
export 'src/widgets/flow_message_actions.dart';
export 'src/styles/flow_message_actions_style.dart';
export 'src/styles/flow_message_style.dart';
export 'src/widgets/flow_model_selector.dart';
export 'src/widgets/flow_pill.dart';
export 'src/styles/flow_pill_style.dart';
export 'src/widgets/flow_shimmer_text.dart';
export 'src/widgets/flow_streaming_text.dart';
export 'src/widgets/flow_suggestion.dart';
export 'src/styles/flow_suggestion_style.dart';
export 'src/widgets/flow_thinking_indicator.dart';
export 'src/widgets/flow_thread.dart';
