import 'package:flutter/widgets.dart';

/// A file the host wants shown as a tile.
///
/// ```dart
/// FlowAttachment(
///   id: 'img-1',
///   thumbnail: NetworkImage(url),
///   kind: 'JPG',
///   label: 'sunset.jpg',
/// )
/// ```
///
/// [thumbnail] is any `ImageProvider`, so network, file, memory and asset
/// images all work — the package never loads anything itself. Leave it null
/// for a file with no image of its own, such as a document: the tile then
/// draws its ground and, when [kind] is set, the type pill.
@immutable
class FlowAttachment {
  const FlowAttachment({
    required this.id,
    this.thumbnail,
    this.preview,
    this.kind,
    this.label,
    this.tooltip,
  });

  /// Reported through `onTap` and `onRemove`.
  final String id;

  /// Drawn in the tile, decoded down to the tile's size. Null for an
  /// attachment with no image to show.
  final ImageProvider? thumbnail;

  /// Drawn full-screen by `FlowAttachmentPreview`; defaults to [thumbnail].
  /// Supply the full-resolution image here when [thumbnail] is a small crop.
  final ImageProvider? preview;

  /// Host-supplied type label for the tile's pill, e.g. 'PDF' or 'JPG'. Drawn
  /// verbatim — the package derives nothing from [label] — and a null [kind]
  /// leaves the pill off.
  final String? kind;

  /// Host-supplied name, e.g. 'sunset.jpg'. Used as the accessibility label
  /// and as the tooltip fallback; the square tile has no room to draw it.
  final String? label;

  /// Host-localized tooltip; falls back to [label].
  final String? tooltip;

  /// The image to show full-screen: [preview] when supplied, otherwise
  /// [thumbnail]. Null when there is no image at all, which is what makes an
  /// attachment unopenable rather than merely thumbnail-less.
  ImageProvider? get previewImage => preview ?? thumbnail;
}
