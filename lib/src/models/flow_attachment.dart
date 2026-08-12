import 'package:flutter/widgets.dart';

/// An image the host wants shown as a thumbnail tile.
///
/// ```dart
/// FlowAttachment(
///   id: 'img-1',
///   thumbnail: NetworkImage(url),
///   label: 'sunset.jpg',
/// )
/// ```
///
/// [thumbnail] is any `ImageProvider`, so network, file, memory and asset
/// images all work — the package never loads anything itself. Document and
/// video attachments are not modelled yet.
@immutable
class FlowAttachment {
  const FlowAttachment({
    required this.id,
    required this.thumbnail,
    this.preview,
    this.label,
    this.tooltip,
  });

  /// Reported through `onTap` and `onRemove`.
  final String id;

  /// Drawn in the tile, decoded down to the tile's size.
  final ImageProvider thumbnail;

  /// Drawn full-screen by `FlowAttachmentPreview`; defaults to [thumbnail].
  /// Supply the full-resolution image here when [thumbnail] is a small crop.
  final ImageProvider? preview;

  /// Host-supplied name, e.g. 'sunset.jpg'. Used as the accessibility label
  /// and as the tooltip fallback; the square tile has no room to draw it.
  final String? label;

  /// Host-localized tooltip; falls back to [label].
  final String? tooltip;
}
