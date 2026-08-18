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

/// A failure surfaced in the turn, rendered by a `FlowErrorState`.
class FlowErrorPart extends FlowMessagePart {
  const FlowErrorPart({this.message, this.retryable = true});

  /// Host-written and sentence-case. Null renders the card without one —
  /// the package ships no strings.
  final String? message;

  /// False suppresses the retry affordance even when the host wires
  /// retry — for failures retrying can't fix.
  final bool retryable;
}

/// Host-defined content, rendered through a `FlowCustomPartBuilder`.
class FlowCustomPart extends FlowMessagePart {
  const FlowCustomPart({required this.type, this.data});

  /// Discriminator the host's builder switches on.
  final String type;

  /// Arbitrary payload for the builder.
  final Object? data;
}
