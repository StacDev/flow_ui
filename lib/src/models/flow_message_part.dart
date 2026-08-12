import 'package:flutter/foundation.dart';

import 'flow_attachment.dart';

/// One piece of content inside a `FlowMessageData`.
///
/// Sealed so renderers can switch exhaustively. More part types (code, tool)
/// arrive alongside their components; [FlowCustomPart] is how hosts inject
/// arbitrary content today.
@immutable
sealed class FlowMessagePart {
  const FlowMessagePart();
}

/// Plain text content.
class FlowTextPart extends FlowMessagePart {
  const FlowTextPart(this.text);

  final String text;
}

/// Image attachments, rendered as a group of thumbnail tiles.
class FlowAttachmentPart extends FlowMessagePart {
  const FlowAttachmentPart(this.attachments);

  final List<FlowAttachment> attachments;
}

/// Host-defined content, rendered through a `FlowCustomPartBuilder`.
class FlowCustomPart extends FlowMessagePart {
  const FlowCustomPart({required this.type, this.data});

  /// Discriminator the host's builder switches on.
  final String type;

  /// Arbitrary payload for the builder.
  final Object? data;
}
