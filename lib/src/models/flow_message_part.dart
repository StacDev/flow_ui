import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show ImageProvider;

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
///
/// Parts render in the order given, so a sent turn's layout is however
/// the host composed the list. The convention is attachments above and
/// the caption under them — put this part ahead of the [FlowTextPart]:
///
/// ```dart
/// FlowMessageData(
///   id: 'm1',
///   role: FlowMessageRole.user,
///   parts: [
///     FlowAttachmentPart(sent),
///     FlowTextPart('What is the peak on the left?'),
///   ],
/// )
/// ```
class FlowAttachmentPart extends FlowMessagePart {
  const FlowAttachmentPart(this.attachments);

  final List<FlowAttachment> attachments;
}

/// A large-format image in a turn — a generated picture presented as
/// content, unlike [FlowAttachmentPart]'s thumbnail tiles.
///
/// A null [image] renders the generating placeholder: a shimmering block
/// at [aspectRatio]. Generation is data, as everywhere — the host
/// re-renders with [image] set when the picture arrives, and the block
/// becomes it.
class FlowImagePart extends FlowMessagePart {
  const FlowImagePart({this.image, this.aspectRatio = 1, this.semanticLabel})
    : assert(aspectRatio > 0, 'aspectRatio must be positive');

  /// The picture; any `ImageProvider`. Null while still generating.
  final ImageProvider? image;

  /// Width over height — shapes the placeholder and the picture's frame
  /// alike, so nothing jumps when the image lands. Defaults to square.
  final double aspectRatio;

  /// Host-written description, read to assistive tech for both the
  /// placeholder and the picture.
  final String? semanticLabel;
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
