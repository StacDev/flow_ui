import 'package:material_ui/material_ui.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_circle_button.dart';
import 'flow_markdown.dart';

/// The phones' path to selecting prose — the AI apps' "Select text": a
/// full-screen page of [text], typeset as markdown on the raised ground,
/// where a long-press
/// selects a word and the platform's handles and toolbar do the rest.
/// Offered from the message menu, since on touch the long-press on the
/// message is the menu itself; on pointer platforms a thread with
/// `selectable` on drag-selects in place and never needs this.
///
/// [text] is usually [FlowMessageData.plainText]. [closeTooltip] names
/// the close disc; a `MaterialApp` host gets its own "Close" when null.
Future<void> showFlowTextSelection({
  required BuildContext context,
  required String text,
  String? closeTooltip,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) =>
          FlowTextSelectionPage(text: text, closeTooltip: closeTooltip),
    ),
  );
}

/// The page [showFlowTextSelection] pushes; usable directly by a host with
/// its own routing.
class FlowTextSelectionPage extends StatelessWidget {
  const FlowTextSelectionPage({
    super.key,
    required this.text,
    this.closeTooltip,
  });

  final String text;
  final String? closeTooltip;

  /// The design's page: the reading inset, the close disc's 24 frame on
  /// the top bar's 12 inset, the body line.
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(20, 8, 20, 40);
  static const EdgeInsets _barPadding = EdgeInsets.fromLTRB(12, 8, 12, 0);
  static const double _closeIconSize = 20;
  static const double _closePadding = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
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
                  // Typeset, not raw: a reply's markdown reads here as it
                  // did in the thread, and every run of it selects.
                  child: FlowMarkdown(
                    text: text,
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurface,
                    ),
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
