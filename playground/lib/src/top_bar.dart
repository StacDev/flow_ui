import 'package:flutter/material.dart';

import 'flow_logo.dart';
import 'shell_palette.dart';
import 'stage.dart';

/// The 54px chrome bar: logo cluster on the left, then the Light/Dark and
/// Web/Mobile segmented switches and the code-panel toggle on the right.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.device,
    required this.onDeviceChanged,
    required this.codeOpen,
    required this.onToggleCode,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final StageDevice device;
  final ValueChanged<StageDevice> onDeviceChanged;
  final bool codeOpen;
  final VoidCallback onToggleCode;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: shell.topBarBg,
        border: Border(bottom: BorderSide(color: shell.border)),
      ),
      child: Row(
        children: [
          const FlowLogo(size: 16),
          const SizedBox(width: 9),
          Text(
            'Flow UI',
            style: shellText(
              size: 15,
              weight: FontWeight.w700,
              letterSpacing: -0.15,
              color: shell.text,
            ),
          ),
          const SizedBox(width: 9),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              'Playground',
              style: shellText(
                size: 11.5,
                weight: FontWeight.w500,
                color: shell.sectionLabel,
              ),
            ),
          ),
          const Spacer(),
          ShellSegmented<ThemeMode>(
            options: const [
              (ThemeMode.light, 'Light'),
              (ThemeMode.dark, 'Dark'),
            ],
            value: themeMode,
            onChanged: onThemeModeChanged,
          ),
          const SizedBox(width: 18),
          ShellSegmented<StageDevice>(
            options: const [
              (StageDevice.web, 'Web'),
              (StageDevice.mobile, 'Mobile'),
            ],
            value: device,
            onChanged: onDeviceChanged,
          ),
          const SizedBox(width: 18),
          _CodeToggle(active: codeOpen, onTap: onToggleCode),
        ],
      ),
    );
  }
}

/// The design's segmented switch: a chip track with a lifted white (or
/// raised-grey, in dark) active pill.
class ShellSegmented<T> extends StatelessWidget {
  const ShellSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: shell.chip,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, (option, label)) in options.indexed) ...[
            if (i > 0) const SizedBox(width: 2),
            _Segment<T>(
              label: label,
              active: option == value,
              onTap: () => onChanged(option),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: active ? shell.segmentActiveBg : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: shell.segmentShadow,
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: shellText(
              size: 12.5,
              weight: FontWeight.w500,
              color: active ? shell.text : shell.segmentRest,
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeToggle extends StatefulWidget {
  const _CodeToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  State<_CodeToggle> createState() => _CodeToggleState();
}

class _CodeToggleState extends State<_CodeToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.active || _hovered ? shell.chip : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Icon(
            Icons.code,
            size: 17,
            color: widget.active ? shell.text : shell.segmentRest,
          ),
        ),
      ),
    );
  }
}
