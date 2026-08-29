import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// A refused file, said in the playground's words: a glyph and a line on
/// the composer's rail that fades out on its own after a beat.
///
/// Host-side by design — flow_ui reports the name and the reason and
/// ships no copy — so this is the shape an app would write for itself.
class RejectionNotice extends StatefulWidget {
  const RejectionNotice({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  final String message;

  /// Called once the fade has finished; the host drops the notice then.
  final VoidCallback onDismissed;

  @override
  State<RejectionNotice> createState() => _RejectionNoticeState();
}

class _RejectionNoticeState extends State<RejectionNotice> {
  static const Duration _hold = Duration(seconds: 4);
  static const Duration _fade = Duration(milliseconds: 300);

  /// The composer card's content inset, so the glyph lines up with the
  /// field's text rather than the card's edge.
  static const double _inset = 18;

  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(RejectionNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new refusal restarts the clock and brings the line back.
    if (oldWidget.message != widget.message) {
      setState(() => _visible = true);
      _arm();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _arm() {
    _timer?.cancel();
    _timer = Timer(_hold, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: _fade,
      // onEnd also fires after a 0 → 1 re-show; only the fade-out
      // dismisses.
      onEnd: () {
        if (!_visible) widget.onDismissed();
      },
      child: Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: _inset),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.warningCircle,
                size: 16,
                color: colors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.flowTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
