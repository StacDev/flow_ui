import 'package:flutter/foundation.dart';

import 'flow_attachment.dart';

/// One piece of content inside a `FlowMessageData`.
///
/// Sealed so renderers can switch exhaustively. More part types (tool)
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

/// Fenced code, rendered by a `FlowCodeBlock`.
class FlowCodePart extends FlowMessagePart {
  const FlowCodePart(this.code, {this.language, this.filename});

  /// The source, verbatim.
  final String code;

  /// `FlowCodeLanguage` id or alias — usually the fence info string, e.g.
  /// `'dart'`. Null or unknown renders plain.
  final String? language;

  /// The block's header label, e.g. a file hint beside the fence. Null
  /// falls back to [language].
  final String? filename;
}

/// Host-defined content, rendered through a `FlowCustomPartBuilder`.
class FlowCustomPart extends FlowMessagePart {
  const FlowCustomPart({required this.type, this.data});

  /// Discriminator the host's builder switches on.
  final String type;

  /// Arbitrary payload for the builder.
  final Object? data;
}
