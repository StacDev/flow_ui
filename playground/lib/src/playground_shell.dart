import 'package:material_ui/material_ui.dart';

import 'code_panel.dart';
import 'demo_registry.dart';
import 'playground_item.dart';
import 'sidebar.dart';
import 'stage.dart';
import 'top_bar.dart';

/// The playground's single screen: top bar over sidebar + canvas + code
/// panel. Owns the stage device, the panel state and the per-item variant
/// memory; the component on the stage comes from the route, and the theme
/// lives with the app so the whole MaterialApp flips.
class PlaygroundShell extends StatefulWidget {
  const PlaygroundShell({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onThemeModeChanged,
  });

  /// The component on the stage — the route's `:component`. The shell
  /// reads it, the router owns it: picking a row navigates, and
  /// navigating (the browser's back button included) restages.
  final PlaygroundItem item;

  /// Selection intent; the app turns it into a route change.
  final ValueChanged<PlaygroundItem> onSelect;

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<PlaygroundShell> createState() => _PlaygroundShellState();
}

class _PlaygroundShellState extends State<PlaygroundShell> {
  StageDevice _device = StageDevice.web;
  bool _codeOpen = true;

  /// The chosen variant per item; items absent fall back to their first.
  final Map<PlaygroundItem, String> _variants = {};

  String? get _variant {
    final variants = variantsFor(widget.item);
    if (variants.isEmpty) return null;
    return _variants[widget.item] ?? variants.first.$1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopBar(
            onThemeModeChanged: widget.onThemeModeChanged,
            device: _device,
            onDeviceChanged: (device) => setState(() => _device = device),
            codeOpen: _codeOpen,
            onToggleCode: () => setState(() => _codeOpen = !_codeOpen),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Sidebar(selected: widget.item, onSelect: widget.onSelect),
                Expanded(
                  child: Stage(
                    device: _device,
                    item: widget.item,
                    variant: _variant,
                    onVariantChanged: (id) =>
                        setState(() => _variants[widget.item] = id),
                  ),
                ),
                CodePanel(
                  open: _codeOpen,
                  item: widget.item,
                  variant: _variant,
                  onClose: () => setState(() => _codeOpen = false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
