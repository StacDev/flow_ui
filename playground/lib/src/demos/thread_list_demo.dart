import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

String threadListSnippet([String? variant]) => switch (variant) {
  'flat' => _flat,
  'icons' => _icons,
  _ => _sections,
};

const String _sections = '''
// Sections are data: the host groups and labels them — 'Pinned',
// 'Today' — and the package renders muted headers between the runs.
// Tapping a row reports its id; opening the thread is the host's move.
FlowThreadList(
  sections: [
    FlowThreadListSection(
      label: 'Pinned',
      items: [
        // pinned draws the muted pin; unread the primary dot and the
        // emphasised title cut.
        FlowThreadListItem(id: 't1', title: 'Trip planning', pinned: true),
      ],
    ),
    FlowThreadListSection(label: 'Today', items: today),
  ],
  selectedId: openThreadId,
  onThreadSelected: openThread,
)''';

const String _flat = '''
// The ungrouped form: one label-less section under the hood. Needs a
// bounded height, like FlowThread — or shrinkWrap: true inside a host
// panel that scrolls on its own.
FlowThreadList.flat(
  items: [
    for (final thread in recents)
      FlowThreadListItem(id: thread.id, title: thread.title),
  ],
  selectedId: openThreadId,
  onThreadSelected: openThread,
)''';

const String _icons = '''
// An optional leading glyph per thread — a project or agent mark.
FlowThreadList.flat(
  items: [
    FlowThreadListItem(
      id: 't1',
      title: 'Design review notes',
      icon: Icons.folder_outlined,
    ),
    FlowThreadListItem(
      id: 't2',
      title: 'Weekly meal plan',
      icon: Icons.restaurant_outlined,
    ),
  ],
  selectedId: openThreadId,
  onThreadSelected: openThread,
)''';

/// One thread the demo owns, mutable so selecting can clear unread the
/// way a real host would.
class _Thread {
  _Thread(this.id, this.title, {this.pinned = false, this.unread = false});

  final String id;
  final String title;
  final bool pinned;
  bool unread;
}

/// Fresh threads per mount — the stage keys demos by variant so pill
/// switches reset local state, which only works if the seed isn't
/// shared.
List<(String?, List<_Thread>)> _seed() => [
  (
    'Pinned',
    [
      _Thread('p1', 'Flow UI component roadmap', pinned: true),
      _Thread('p2', 'Tokyo trip planning', pinned: true, unread: true),
    ],
  ),
  (
    'Today',
    [
      _Thread('t1', 'Debugging the composer outline'),
      _Thread('t2', 'Draft: launch announcement blog post and release notes'),
      _Thread('t3', 'Weekly meal plan', unread: true),
    ],
  ),
  (
    'Previous 7 days',
    [
      _Thread('y1', 'Recipe: shakshuka'),
      _Thread('y2', 'Regex for semver ranges'),
      _Thread('y3', 'Gift ideas'),
    ],
  ),
];

/// The conversation history at sidebar proportions. Sections shows the
/// grouped form — pinned and unread marks included, one long title
/// ellipsizing under a tooltip; Flat is the ungrouped `.flat` form; With
/// icons adds the leading glyph. The demo owns selection, and opening a
/// thread clears its unread mark, the way a real host would.
class ThreadListDemo extends StatefulWidget {
  const ThreadListDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ThreadListDemo> createState() => _ThreadListDemoState();
}

class _ThreadListDemoState extends State<ThreadListDemo> {
  final List<(String?, List<_Thread>)> _sections = _seed();
  String? _selectedId = 't1';

  void _select(String id) {
    setState(() {
      _selectedId = id;
      for (final (_, threads) in _sections) {
        for (final thread in threads) {
          if (thread.id == id) thread.unread = false;
        }
      }
    });
  }

  FlowThreadListItem _item(_Thread thread, {bool icons = false}) {
    return FlowThreadListItem(
      id: thread.id,
      title: thread.title,
      icon: icons ? _iconFor(thread.id) : null,
      pinned: thread.pinned,
      unread: thread.unread,
      // The long Today title ellipsizes; its tooltip carries the rest.
      tooltip: thread.id == 't2' ? thread.title : null,
      semanticLabel: thread.unread ? '${thread.title}, unread' : null,
    );
  }

  static IconData _iconFor(String id) => switch (id) {
    'p1' => PhosphorIconsRegular.palette,
    'p2' => PhosphorIconsRegular.airplaneTilt,
    't1' => PhosphorIconsRegular.bug,
    't2' => PhosphorIconsRegular.article,
    't3' => PhosphorIconsRegular.forkKnife,
    'y1' => PhosphorIconsRegular.cookingPot,
    'y2' => PhosphorIconsRegular.textAa,
    _ => PhosphorIconsRegular.gift,
  };

  @override
  Widget build(BuildContext context) {
    final Widget list;
    if (widget.variant == 'flat' || widget.variant == 'icons') {
      // Both flat forms; With icons adds the leading glyph per thread.
      final icons = widget.variant == 'icons';
      list = FlowThreadList.flat(
        items: [
          for (final (_, threads) in _sections)
            for (final thread in threads) _item(thread, icons: icons),
        ],
        selectedId: _selectedId,
        onThreadSelected: _select,
      );
    } else {
      list = FlowThreadList(
        sections: [
          for (final (label, threads) in _sections)
            FlowThreadListSection(
              label: label,
              items: [for (final thread in threads) _item(thread)],
            ),
        ],
        selectedId: _selectedId,
        onThreadSelected: _select,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: SizedBox(height: 480, child: list),
      ),
    );
  }
}
