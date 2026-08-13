import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'gallery_app_bar.dart';
import 'phone_frame.dart';

/// The shared scaffold for a component page: the gallery app bar (title +
/// class-name subtitle), an optional one-line description, and the demo
/// content centered in a reading-width column.
///
/// The width cap is what keeps demo cards composed on a wide monitor —
/// without it a 32dp trigger floats in 1600dp of card.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    this.className,
    this.description,
    required this.children,
  }) : child = null;

  /// A page whose demo *is* the page: [child] gets the pane's full height,
  /// with no scroll view and no reading-width cap.
  ///
  /// Surfaces need this. A `FlowChatScreen` in the scrolling body above has
  /// to be given an arbitrary `SizedBox` height, which is exactly the
  /// bounded-height workaround the component exists to remove.
  const GalleryPage.filling({
    super.key,
    required this.title,
    this.className,
    required Widget this.child,
  }) : description = null,
       children = const [];

  /// The page title, matching the sidebar entry.
  final String title;

  /// The widget class being demoed, shown as the app bar subtitle.
  final String? className;

  /// One muted line under the header: what the widget is, and what to try.
  final String? description;

  /// The page content — demo cards and section headers.
  final List<Widget> children;

  /// Set by [GalleryPage.filling]; replaces the scrolling body entirely.
  final Widget? child;

  /// Reading width for demo content.
  static const double maxContentWidth = 860;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;

    final child = this.child;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: GalleryAppBar(title: title, subtitle: className),
      // The shell hands each page a bounded pane; only the scrolling body
      // discards that height, so a filling page simply doesn't add one.
      body: ViewportBody(
        child:
            child ??
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (description != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              description!,
                              style: typography.bodyMedium.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
