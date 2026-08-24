import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'playground_item.dart';
import 'playground_shell.dart';

/// The playground's URL contract: one path per component —
/// `/playground/composer`, `/playground/full-chat` — so a component can be
/// linked, bookmarked and reached with the back button.
///
/// Only the component is an address. The variant pills, the theme and the
/// device frame are workbench settings that travel with the person, not
/// the link, so they stay in the shell's state.
///
/// The docs site's chrome-less embeds keep their own query contract
/// (`index.html?embed=…`) and never reach this router — `main` branches on
/// them before the app is built.
GoRouter playgroundRouter({
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) {
  return GoRouter(
    initialLocation: _defaultLocation,
    // Everything that isn't a known component — `/`, a typo, a stale link
    // — lands on the example rather than a dead end, the same never-crash
    // contract the embed's "Unknown demo" surface keeps. The rewrite
    // replaces the history entry on first load, so Back still leaves.
    redirect: (context, state) {
      final segments = state.uri.pathSegments;
      if (segments.length == 1 &&
          playgroundItemForSlug(segments.single) != null) {
        return null;
      }
      return _defaultLocation;
    },
    routes: [
      GoRoute(
        path: '/:component',
        // One page for every component, under one key: the Navigator
        // updates it in place instead of swapping routes, so the shell's
        // state — the per-item variant memory, the device, the code panel
        // — survives navigation. No transition either: the stage swaps,
        // the chrome around it doesn't move.
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: const ValueKey('playground-shell'),
          name: state.pathParameters['component'],
          child: PlaygroundShell(
            item: playgroundItemForSlug(state.pathParameters['component']!)!,
            onSelect: (item) => context.go('/${item.slug}'),
            onThemeModeChanged: onThemeModeChanged,
          ),
        ),
      ),
    ],
  );
}

/// The example leads the sidebar, so it leads the playground.
final String _defaultLocation = '/${PlaygroundItem.fullChat.slug}';
