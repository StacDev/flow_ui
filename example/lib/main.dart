import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'pages/add_menu_page.dart';
import 'pages/attachment_page.dart';
import 'pages/composer_page.dart';
import 'pages/loading_indicator_page.dart';
import 'pages/message_actions_page.dart';
import 'pages/message_thread_page.dart';
import 'pages/model_selector_page.dart';
import 'pages/streaming_text_page.dart';
import 'pages/suggestion_page.dart';
import 'pages/tokens_page.dart';
import 'widgets/code_block.dart';
import 'widgets/gallery_app_bar.dart';
import 'widgets/gallery_scope.dart';
import 'widgets/gallery_sidebar.dart';
import 'widgets/phone_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads the Dart grammar and both highlight themes once, so every
  // CodeBlock renders synchronously.
  await CodeHighlighting.init();
  runApp(const GalleryApp());
}

/// Every component in the gallery, grouped the way the library is layered —
/// the one list both layouts render: the sidebar + preview shell on wide
/// windows, the tile list on narrow ones.
final List<GalleryGroup> galleryGroups = [
  GalleryGroup(
    label: 'Foundation',
    entries: [
      GalleryEntry(
        title: 'Design tokens',
        subtitle: 'Colors, typography, spacing, radii',
        icon: Icons.palette_outlined,
        builder: (_) => const TokensPage(),
      ),
    ],
  ),
  GalleryGroup(
    label: 'Conversation',
    entries: [
      GalleryEntry(
        title: 'Message & Thread',
        subtitle: 'FlowMessage & FlowThread — conversation rendering',
        icon: Icons.forum_outlined,
        builder: (_) => const MessageThreadPage(),
      ),
      GalleryEntry(
        title: 'Message actions',
        subtitle: 'FlowMessageActions — copy, regenerate, feedback',
        icon: Icons.thumbs_up_down_outlined,
        builder: (_) => const MessageActionsPage(),
      ),
      GalleryEntry(
        title: 'Streaming text',
        subtitle: 'FlowStreamingText — animated streaming reveal',
        icon: Icons.notes_rounded,
        builder: (_) => const StreamingTextPage(),
      ),
      GalleryEntry(
        title: 'Loading indicator',
        subtitle: 'FlowLoadingIndicator — staggered three-dot pulse',
        icon: Icons.more_horiz_rounded,
        builder: (_) => const LoadingIndicatorPage(),
      ),
    ],
  ),
  GalleryGroup(
    label: 'Input',
    entries: [
      GalleryEntry(
        title: 'Message composer',
        subtitle: 'FlowComposer — input, send/stop, action slots',
        icon: Icons.edit_outlined,
        builder: (_) => const ComposerPage(),
      ),
      GalleryEntry(
        title: 'Model selector',
        subtitle: 'FlowModelSelector — model picker menu',
        icon: Icons.tune_rounded,
        builder: (_) => const ModelSelectorPage(),
      ),
      GalleryEntry(
        title: 'Add menu',
        subtitle: 'FlowAddMenu — the "+" menu: attachments, tools',
        icon: Icons.add_circle_outline,
        builder: (_) => const AddMenuPage(),
      ),
      GalleryEntry(
        title: 'Attachments',
        subtitle: 'FlowAttachment & FlowAttachmentGroup — image thumbnails',
        icon: Icons.image_outlined,
        builder: (_) => const AttachmentPage(),
      ),
      GalleryEntry(
        title: 'Suggestions',
        subtitle: 'FlowSuggestion & FlowSuggestionGroup — prompt starters',
        icon: Icons.lightbulb_outline,
        builder: (_) => const SuggestionPage(),
      ),
    ],
  ),
];

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _mode = ThemeMode.light;
  bool _mobileView = false;

  void _toggleMode() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleViewport() {
    setState(() => _mobileView = !_mobileView);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flow_ui gallery',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [FlowTheme.light()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [FlowTheme.dark()],
      ),
      // Above the navigator, so every pushed page shares the same viewport
      // and theme toggles.
      builder: (context, child) => GalleryScope(
        mobileView: _mobileView,
        onToggleViewport: _toggleViewport,
        onToggleTheme: _toggleMode,
        child: child!,
      ),
      home: const GalleryShell(),
    );
  }
}

/// The gallery layout: components on the left, the selected one previewed
/// on the right. Below 840dp it falls back to the tile list that pushes
/// each page — the two panes need a desktop window's room.
class GalleryShell extends StatefulWidget {
  const GalleryShell({super.key});

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  GalleryEntry _selected = galleryGroups.first.entries.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) return const GalleryHomePage();
        return Scaffold(
          backgroundColor: context.flowColors.surface,
          body: Row(
            children: [
              GallerySidebar(
                groups: galleryGroups,
                selected: _selected,
                onSelect: (entry) => setState(() => _selected = entry),
              ),
              // The page brings its own Scaffold and app bar, which double
              // as the preview pane's header.
              Expanded(child: _selected.builder(context)),
            ],
          ),
        );
      },
    );
  }
}

/// The narrow-window gallery: grouped tiles, one push per page.
class GalleryHomePage extends StatelessWidget {
  const GalleryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const GalleryAppBar(title: 'flow_ui gallery'),
      body: ViewportBody(
        child: ListView(
          padding: EdgeInsets.all(spacing.lg),
          children: [
            for (final group in galleryGroups) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.xs,
                  spacing.lg,
                  spacing.xs,
                  spacing.sm,
                ),
                child: Text(
                  group.label.toUpperCase(),
                  style: typography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              for (final entry in group.entries) _DemoTile(entry: entry),
            ],
          ],
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.entry});

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;

    return Container(
      margin: EdgeInsets.only(bottom: context.flowSpacing.sm),
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: context.flowRadii.md,
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(entry.icon, color: colors.primary),
          title: Text(
            entry.title,
            style: typography.titleMedium.copyWith(color: colors.onSurface),
          ),
          subtitle: Text(
            entry.subtitle,
            style: typography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: entry.builder));
          },
        ),
      ),
    );
  }
}
