import 'package:flutter/material.dart';

/// The sidebar's destinations — one example plus the component demos to
/// come. [codeFile] is the filename the code panel shows for the item,
/// per the design's snippets.
enum PlaygroundItem {
  fullChat(
    'Full Chat',
    Icons.wb_twilight,
    'full_chat_screen.dart',
    isExample: true,
  ),
  composer('Composer', Icons.format_align_left, 'flow_composer.dart'),
  modalSelector(
    'Modal Selector',
    Icons.expand_more,
    'flow_model_selector.dart',
  ),
  message('Message', Icons.chat_bubble_outline, 'flow_message.dart'),
  streamingMessage(
    'Streaming Message',
    Icons.emergency,
    'flow_streaming_message.dart',
  ),
  addToChat('Add to Chat', Icons.add, 'flow_add_to_chat_menu.dart'),
  attachments('Attachments', Icons.attach_file, 'flow_attachments.dart');

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
