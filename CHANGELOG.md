# Changelog

## 0.2.0 (unreleased)

flow_ui now builds on `package:material_ui` — Material's home since
Flutter 3.47 moved the design libraries out of the SDK. Every widget keeps
its name and shape: the change is the foundation, not the API.

It does mean the app must be on material_ui too. The legacy
`package:flutter/material.dart` and material_ui are distinct types — a
legacy `ThemeData(extensions:)` won't accept `FlowTheme`, and the compiler
says so out loud. Migrate the app with
`dart fix --apply --code=migrate_design_widgets` (Flutter 3.44 or newer);
apps staying on the legacy import should pin flow_ui 0.1.x.

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
