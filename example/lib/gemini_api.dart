import 'dart:async';
import 'dart:convert';

import 'package:flow_ui/flow_ui.dart';
import 'package:http/http.dart' as http;

/// Minimal Gemini client for the example app — the host-side transport.
///
/// flow_ui never sees it: the conversation goes in as the screen's
/// [FlowMessageData] list, and the reply comes back as a stream of text
/// deltas the screen folds into its own state. Everything model-facing
/// stays on this side of the boundary.
class GeminiApi {
  GeminiApi({required this.apiKey, this.model = 'gemini-3.6-flash'});

  final String apiKey;
  final String model;

  static const String _host = 'generativelanguage.googleapis.com';

  /// Streams the reply to [history] as text deltas.
  ///
  /// [history] is the conversation so far, oldest first; user turns are
  /// sent as `user`, assistant turns as `model`, and everything that
  /// isn't a successful turn (system turns, failed turns) is skipped.
  ///
  /// Attached images ride along as `inlineData`: flow_ui hands back the
  /// bytes it read, this encodes them. Throws a [GeminiApiException] with
  /// the API's own message when the request is refused.
  Stream<String> streamReply(List<FlowMessageData> history) async* {
    if (apiKey.isEmpty) {
      throw GeminiApiException(
        'No API key. Paste yours into example/lib/env.g.dart — grab one '
        'from Google AI Studio.',
      );
    }

    final client = http.Client();
    try {
      final request =
          http.Request(
              'POST',
              Uri.https(_host, '/v1beta/models/$model:streamGenerateContent', {
                'alt': 'sse',
              }),
            )
            ..headers['x-goog-api-key'] = apiKey
            ..headers['content-type'] = 'application/json'
            ..body = jsonEncode({'contents': _contentsFrom(history)});

      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw GeminiApiException(
          _errorMessage(
            await response.stream.bytesToString(),
            response.statusCode,
          ),
        );
      }

      // The SSE stream: one `data: {json}` line per chunk.
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final delta = _textFrom(line.substring(6));
        if (delta.isNotEmpty) yield delta;
      }
    } finally {
      client.close();
    }
  }

  static List<Map<String, Object?>> _contentsFrom(
    List<FlowMessageData> history,
  ) {
    final contents = <Map<String, Object?>>[];
    for (final message in history) {
      // A failed turn can carry the partial text streamed before the
      // error; replaying it as a successful `model` message would make
      // Gemini continue from its own aborted reply.
      if (message.role == FlowMessageRole.system ||
          message.status == FlowMessageStatus.error) {
        continue;
      }
      final parts = _partsOf(message);
      if (parts.isEmpty) continue;
      contents.add({
        'role': message.role == FlowMessageRole.user ? 'user' : 'model',
        'parts': parts,
      });
    }
    return contents;
  }

  /// A turn's text and its images, in Gemini's shape.
  ///
  /// The bytes come straight off the [FlowAttachment]s flow_ui built when
  /// the user picked or dropped the file — the package reads and decodes,
  /// and leaves both the original bytes and their type on the attachment
  /// for exactly this. Anything without bytes, or without an image type,
  /// is display-only and skipped.
  static List<Map<String, Object?>> _partsOf(FlowMessageData message) {
    final parts = <Map<String, Object?>>[];

    // Walked in order, so what the model reads matches what the bubble
    // shows: the picture first and the caption under it, the way the
    // turn was composed.
    for (final part in message.parts) {
      switch (part) {
        case FlowTextPart(:final text) when text.isNotEmpty:
          parts.add({'text': text});
        case FlowAttachmentPart(:final attachments):
          for (final attachment in attachments) {
            final bytes = attachment.bytes;
            final mimeType = attachment.mimeType;
            if (bytes == null || mimeType == null) continue;
            if (!mimeType.startsWith('image/')) continue;
            // inlineData is capped by the request size (~20MB), and
            // base64 inflates by a third — the composer's 10MB ceiling
            // keeps a single image well inside it.
            parts.add({
              'inlineData': {'mimeType': mimeType, 'data': base64Encode(bytes)},
            });
          }
        default:
          break;
      }
    }
    return parts;
  }

  static String _textFrom(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>? ?? const [];
      if (candidates.isEmpty) return '';
      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>? ?? const [];
      return [
        for (final part in parts)
          if (part case {'text': final String text}) text,
      ].join();
    } on FormatException {
      return '';
    }
  }

  static String _errorMessage(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['error'] case {'message': final String message}) {
        return message;
      }
    } on FormatException {
      // Fall through to the generic message.
    }
    return 'Gemini returned HTTP $statusCode.';
  }
}

/// A refused request, carrying the API's message for the error card.
class GeminiApiException implements Exception {
  GeminiApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
