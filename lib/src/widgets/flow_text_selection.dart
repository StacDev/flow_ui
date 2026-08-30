import 'package:material_ui/material_ui.dart';

import '../models/flow_message_data.dart';
import '../models/flow_message_part.dart';
import '../theme/flow_theme.dart';
import '../utils/flow_circle_button.dart';
import 'flow_code_block.dart';
import 'flow_markdown.dart';

/// The phones' path to selecting prose — the AI apps' "Select text": a
/// full-screen page of [message] on the raised ground, typeset as it was
/// in the thread, where a long-press selects a word and the platform's
/// handles and toolbar do the rest. Offered from the message menu, since
/// on touch the long-press on the message is the menu itself; on pointer
/// platforms a thread with `selectable` on drag-selects in place and
/// never needs this.
///
/// [closeTooltip] names the close disc; a `MaterialApp` host gets its own
/// "Close" when null.
Future<void> showFlowTextSelection({
  required BuildContext context,
  required FlowMessageData message,
  String? closeTooltip,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) =>
          FlowTextSelectionPage(message: message, closeTooltip: closeTooltip),
    ),
  );
}

/// The page [showFlowTextSelection] pushes; usable directly by a host with
/// its own routing. Text parts read as they did in the thread — an
/// assistant's as markdown, a user's as typed — and code parts as code
/// blocks; attachments and pictures are left out, there being nothing in
/// them to select.
class FlowTextSelectionPage extends StatelessWidget {
  const FlowTextSelectionPage({
    super.key,
    required this.message,
    this.closeTooltip,
  });

  final FlowMessageData message;
  final String? closeTooltip;

  /// The design's page: the reading inset, the close disc's 32 frame on
  /// the top bar's 12 inset, the body line, 16 between parts.
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(20, 8, 20, 40);
  static const EdgeInsets _barPadding = EdgeInsets.fromLTRB(12, 8, 12, 0);
  static const double _closeIconSize = 20;
  static const double _closePadding = 6;
  static const double _closeTouch = 44;
  static const double _partGap = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final body = typography.bodyLarge.copyWith(color: colors.onSurface);
    final markdown = message.role == FlowMessageRole.assistant;

    final parts = <Widget?>[
      for (final part in message.parts)
        switch (part) {
          FlowTextPart() =>
            markdown
                ? FlowMarkdown(text: part.text, style: body)
                : Text(part.text, style: body),
          FlowCodePart() => FlowCodeBlock(
            code: part.code,
            language: part.language,
            filename: part.filename,
          ),
          _ => null,
        },
    ].nonNulls.toList();

    return Material(
      color: colors.surfaceBright,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _barPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlowCircleButton(
                    icon: Icons.close,
                    background: colors.surfaceContainerLow,
                    foreground: colors.onSurfaceVariant,
                    iconSize: _closeIconSize,
                    padding: _closePadding,
                    touchMinSize: _closeTouch,
                    tooltip:
                        closeTooltip ??
                        // Not MaterialLocalizations.of: a missing tooltip
                        // must not be the one thing that throws under a
                        // plain WidgetsApp.
                        Localizations.of<MaterialLocalizations>(
                          context,
                          MaterialLocalizations,
                        )?.closeButtonTooltip,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SelectionArea(
                child: SingleChildScrollView(
                  padding: _bodyPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < parts.length; i++) ...[
                        if (i > 0) const SizedBox(height: _partGap),
                        parts[i],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
