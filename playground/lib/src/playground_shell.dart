import 'package:material_ui/material_ui.dart';

import 'code_panel.dart';
import 'demo_registry.dart';
import 'playground_item.dart';
import 'sidebar.dart';
import 'stage.dart';
import 'top_bar.dart';

/// The playground's single screen: top bar over sidebar + canvas + code
/// panel. Owns the selection, the stage device, and the panel state; the
/// theme lives with the app so the whole MaterialApp flips.
class PlaygroundShell extends StatefulWidget {
  const PlaygroundShell({super.key, required this.onThemeModeChanged});

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<PlaygroundShell> createState() => _PlaygroundShellState();
}

class _PlaygroundShellState extends State<PlaygroundShell> {
  PlaygroundItem _selected = PlaygroundItem.fullChat;
  StageDevice _device = StageDevice.web;
  bool _codeOpen = true;

  /// The chosen variant per item; items absent fall back to their first.
  final Map<PlaygroundItem, String> _variants = {};

  String? get _variant {
    final variants = variantsFor(_selected);
    if (variants.isEmpty) return null;
    return _variants[_selected] ?? variants.first.$1;
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
                Sidebar(
                  selected: _selected,
                  onSelect: (item) => setState(() => _selected = item),
                ),
                Expanded(
                  child: Stage(
                    device: _device,
                    item: _selected,
                    variant: _variant,
                    onVariantChanged: (id) =>
                        setState(() => _variants[_selected] = id),
                  ),
                ),
                CodePanel(
                  open: _codeOpen,
                  item: _selected,
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
