import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'demo_registry.dart';
import 'playground_item.dart';

/// A parsed `?embed=` request — the chrome-less mode the docs site iframes.
///
/// URL contract (query params, so static hosting needs no route config):
///
///     /playground/?embed=composer&variant=streaming&theme=dark
///
/// `embed` is a [PlaygroundItem] in kebab-case (`full-chat`,
/// `modal-selector`…; the enum name itself is accepted too). `variant`
/// must be one of the item's [variantsFor] ids and falls back to the
/// default otherwise. `theme` is `light` or `dark` — fixed for the
/// session; the docs page reloads the iframe when its theme flips. Left
/// out, the embed follows the OS scheme (light when none is reported).
class EmbedRequest {
  const EmbedRequest({
    required this.item,
    this.variant,
    required this.themeMode,
  });

  /// Null when `embed=` named no known item — render the fallback surface,
  /// never crash inside somebody's docs page.
  final PlaygroundItem? item;
  final String? variant;
  final ThemeMode themeMode;

  /// Null when the URL has no `embed` parameter at all — boot the full
  /// playground instead.
  static EmbedRequest? fromUri(Uri uri) {
    final id = uri.queryParameters['embed'];
    if (id == null || id.isEmpty) return null;

    PlaygroundItem? item;
    for (final candidate in PlaygroundItem.values) {
      if (candidate.name == id || candidate.slug == id) {
        item = candidate;
        break;
      }
    }

    String? variant = uri.queryParameters['variant'];
    if (item != null &&
        !variantsFor(item).any((entry) => entry.$1 == variant)) {
      variant = null;
    }

    return EmbedRequest(
      item: item,
      variant: variant,
      themeMode: switch (uri.queryParameters['theme']) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      },
    );
  }
}

/// The embed app: the same FlowTheme setup as the playground, one demo on
/// a bare surface, no shell chrome and no variant pills — the embedding
/// docs section has already chosen the variant.
class EmbedApp extends StatelessWidget {
  const EmbedApp({super.key, required this.request});

  final EmbedRequest request;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flow_ui demo',
      debugShowCheckedModeBanner: false,
      themeMode: request.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [FlowTheme.light()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [FlowTheme.dark()],
      ),
      home: _EmbedScreen(request: request),
    );
  }
}

class _EmbedScreen extends StatelessWidget {
  const _EmbedScreen({required this.request});

  final EmbedRequest request;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final item = request.item;

    if (item == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Text(
            'Unknown demo',
            style: context.flowTypography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
        ),
      );
    }

    final demo = demoFor(item, variant: request.variant);
    // Mirrors the stage's hosting: a full-surface demo owns the pane,
    // object demos centre on the surface with room to scroll.
    final body = demoFillsStage(item, variant: request.variant)
        ? demo
        : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: demo,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(child: body),
    );
  }
}
