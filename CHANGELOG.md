# Changelog

## 0.2.0 (unreleased)

- **Typography** — title and label roles now carry an emphasised cut
  (`titleLargeEmphasised` / `labelLargeEmphasised`, and the medium/small
  pair for each). The standard scale sizes and line heights are retuned
  to the design file: display at 1.15, headline at 1.2, title/label at
  1.3. Compact `FlowGreeting` uses `titleMedium` instead of a one-off 21.
- **Breaking**: constructing `FlowTypography(...)` now requires the new
  title and label emphasised styles. `FlowTypography.standard` and
  `copyWith` cover the usual host paths; label sizes also step up one
  rung (16 / 14 / 12).
- **Code block** — `FlowCodeBlock`, and a `FlowCodePart` message part
  rendered by `FlowMessage`/`FlowThread` with copy intent surfaced on
  `onCodeCopy`. Highlighting is built in and synchronous (Dart, JSON,
  JavaScript/TypeScript, Python, shell, YAML, HTML, CSS and SQL;
  host-extensible via `FlowCodeLanguage.register`), colored by new
  `FlowSyntaxColors` theme tokens. The package now also bundles Geist Mono (three weights, SIL OFL)
  behind new `code` / `codeInline` typography roles — `withFontFamily()`
  no longer touches the mono roles; swap those with
  `withCodeFontFamily()`.
- **Error state** — `FlowErrorState` (error glyph, host-written message,
  retry pill) and a `FlowErrorPart` message part, with
  `onRetry`/`errorTitle`/`retryLabel` threaded through `FlowMessage` and
  `FlowThread`.
- **Pill** — `FlowPill`, a removable pill showing an enabled tool or mode
  in the composer's action row: host-passed icon, label and tooltips,
  removal intent on `onRemove`, and a label that auto-drops to the
  icon-only form on phones (`showLabel` forces either).
- **Breaking**: `FlowChatScreen` is renamed to `FlowChatView`. The widget
  was never a screen — it is body-only and embeddable, and upcoming
  surfaces (side panel, modal) will host it — so the name now follows
  Flutter's convention for embeddable composites. Rename call sites;
  the API is unchanged.
- **Breaking**: a failed assistant turn no longer recolors its content
  into an `errorContainer` bubble — parts keep their normal ink and the
  turn closes with an error card (a default one when no `FlowErrorPart`
  is present). The user bubble's error treatment is unchanged.
- **Breaking**: migrated from `package:flutter/material.dart` to
  `package:material_ui` (Material's home since Flutter 3.47) — no API
  changes, but the two Materials are distinct types, so the host app must
  migrate too: `dart fix --apply --code=migrate_design_widgets` on
  Flutter 3.44+, or pin flow_ui 0.1.x.

## 0.1.0

First public release — the assistant UI component library for Flutter, with
zero third-party dependencies and nothing model-facing.

Ships with:

- **Theme** — `FlowTheme` design tokens (colors + typography) as a
  `ThemeExtension`, light and dark presets, bundled Figtree typeface.
- **Message & Thread** — ink-wash user bubble, plain assistant, error state,
  typed content parts with a `FlowCustomPart` extension seam.
- **Streaming** — animated text reveal, thinking indicator, shimmer text.
- **Message actions** — copy / regenerate / edit / feedback presets.
- **Composer** — multiline input with send/stop, attachments strip, and
  leading/trailing action slots.
- **Menus** — `FlowMenu` (groups, submenus, toggles) and `FlowModelSelector`
  (effort + overflow submenus); anchored card on desktop, sheet on phones.
- **Attachments** — image and file tiles with type pill, plus a full-screen
  preview with zoom and paging.
- **Suggestions** — plain and outlined starters in scroll, wrap, or column
  layouts, with `FlowGreeting` for the zero state.
- **Chat Screen** — the composed surface: centred 760 rail, zero state with
  lifted composer, jump-to-latest.

## 0.0.1

Initial scaffold.
