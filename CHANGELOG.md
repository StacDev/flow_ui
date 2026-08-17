# Changelog

## 0.2.0 (unreleased)

- **Code block** — `FlowCodeBlock`, and a `FlowCodePart` message part
  rendered by `FlowMessage`/`FlowThread` with copy intent surfaced on
  `onCodeCopy`. Highlighting is built in and synchronous (Dart, JSON,
  JavaScript/TypeScript, Python and shell; host-extensible via
  `FlowCodeLanguage.register`), colored by new `FlowSyntaxColors` theme
  tokens. The package now also bundles Geist Mono (three weights, SIL OFL)
  behind new `code` / `codeInline` typography roles — `withFontFamily()`
  no longer touches the mono roles; swap those with
  `withCodeFontFamily()`.
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
