import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

String pillSnippet([String? variant]) => switch (variant) {
  'icon' => _iconSnip,
  'static' => _staticSnip,
  _ => _composerSnip,
};

const String _iconSnip = '''
// On phones the label auto-drops to the design's icon-only form;
// showLabel forces either.
FlowPill(
  icon: PhosphorIconsRegular.globe,
  label: 'Web Search',
  showLabel: false,
  removeTooltip: 'Turn off Web Search',
  onRemove: () => setWebSearch(false),
)''';

const String _staticSnip = '''
// No onRemove renders a static pill; enabled: false mutes one.
FlowPill(
  icon: PhosphorIconsRegular.graduationCap,
  label: 'Research',
)

FlowPill(
  icon: PhosphorIconsRegular.globe,
  label: 'Web Search',
  enabled: false,
  removeTooltip: 'Turn off Web Search',
  onRemove: turnOff,
)''';

const String _composerSnip = '''
// Presence is the state: the host renders a pill while its tool is on,
// and the X only reports intent — removal is the host's move.
FlowComposer(
  onSend: send,
  leadingActions: [
    FlowMenu(
      icon: PhosphorIconsRegular.plus,
      sheetTitle: 'Add to Chat',
      entries: [...],
      onSelected: toggleTool,
    ),
    if (researchOn)
      FlowPill(
        icon: PhosphorIconsRegular.graduationCap,
        label: 'Research',
        removeTooltip: 'Turn off Research',
        onRemove: () => setResearch(false),
      ),
  ],
)

// On phones the label auto-drops to the design's icon-only form;
// showLabel forces either. No onRemove renders a static pill.
FlowPill(
  icon: PhosphorIconsRegular.globe,
  label: 'Web Search',
  showLabel: false,
  removeTooltip: 'Turn off Web Search',
  onRemove: () => setWebSearch(false),
)''';

/// Stage demo for `FlowPill` — removable tool pills, the forced icon-only
/// form, the static and disabled tokens, and live wiring in a composer
/// whose add menu toggles them.
class PillDemo extends StatefulWidget {
  const PillDemo({super.key, this.variant});

  final String? variant;

  @override
  State<PillDemo> createState() => _PillDemoState();
}

class _PillDemoState extends State<PillDemo> {
  static const double _pillGap = 8;

  bool _researchOn = true;
  bool _webSearchOn = true;

  List<Widget> _pills({bool? showLabel}) => [
    if (_researchOn)
      FlowPill(
        icon: PhosphorIconsRegular.graduationCap,
        label: 'Research',
        showLabel: showLabel,
        removeTooltip: 'Turn off Research',
        onRemove: () => setState(() => _researchOn = false),
      ),
    if (_webSearchOn)
      FlowPill(
        icon: PhosphorIconsRegular.globe,
        label: 'Web Search',
        showLabel: showLabel,
        removeTooltip: 'Turn off Web Search',
        onRemove: () => setState(() => _webSearchOn = false),
      ),
  ];

  /// Both pills removed: the stage resets on a variant switch, so say so
  /// rather than standing empty.
  Widget _row(BuildContext context, {bool? showLabel}) {
    final pills = _pills(showLabel: showLabel);
    if (pills.isEmpty) {
      return Text(
        'Removed — switch variants to bring the pills back.',
        textAlign: TextAlign.center,
        style: context.flowTypography.bodyMedium.copyWith(
          color: context.flowColors.onSurfaceMuted,
        ),
      );
    }
    return Wrap(
      spacing: _pillGap,
      runSpacing: _pillGap,
      alignment: WrapAlignment.center,
      children: pills,
    );
  }

  Widget _composer() {
    return FlowComposer(
      placeholder: 'How can I help you today?',
      onSend: (_) {},
      leadingActions: [
        FlowMenu(
          icon: PhosphorIconsRegular.plus,
          tooltip: 'Add to chat',
          sheetTitle: 'Add to Chat',
          entries: [
            FlowMenuOption(
              id: 'research',
              icon: PhosphorIconsRegular.graduationCap,
              label: 'Research',
              selected: _researchOn,
            ),
            FlowMenuOption(
              id: 'web-search',
              icon: PhosphorIconsRegular.globe,
              label: 'Web Search',
              selected: _webSearchOn,
            ),
          ],
          onSelected: (id) => setState(() {
            if (id == 'research') _researchOn = !_researchOn;
            if (id == 'web-search') _webSearchOn = !_webSearchOn;
          }),
        ),
        ..._pills(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.variant) {
      'icon' => _row(context, showLabel: false),
      'static' => Wrap(
        spacing: _pillGap,
        runSpacing: _pillGap,
        alignment: WrapAlignment.center,
        children: [
          const FlowPill(
            icon: PhosphorIconsRegular.graduationCap,
            label: 'Research',
          ),
          FlowPill(
            icon: PhosphorIconsRegular.globe,
            label: 'Web Search',
            enabled: false,
            removeTooltip: 'Turn off Web Search',
            onRemove: () {},
          ),
        ],
      ),
      'composer' => _composer(),
      _ => _row(context),
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: child,
      ),
    );
  }
}
