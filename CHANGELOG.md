# Changelog

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

For hosts tracking the unpublished `0.0.x` scaffold: the metric tokens are
gone. `FlowSpacing` and `FlowRadii` are removed, along with
`FlowTheme.spacing`, `FlowTheme.radii`, and the `context.flowSpacing` /
`context.flowRadii` extensions. Following Material's structure, each
component now bakes its metrics from the Flow UI design file and exposes
per-widget overrides where hosts retheme:

- `FlowComposer.padding` / `FlowComposer.borderRadius`
- `FlowMessage.bubbleRadius` / `FlowMessage.bubblePadding`
- `FlowAttachmentGroup.tileRadius`
- `FlowSuggestion.padding` / `FlowSuggestion.borderRadius`
- `FlowMenuStyle.sheetRadius` (bottom-sheet corners; `menuRadius` covers the
  anchored card)

`FlowTheme` carries colors and typography only. `FlowComposer`'s default
padding is direction-aware (`EdgeInsetsDirectional`), so RTL layouts mirror
correctly.

## 0.0.1

Initial scaffold.
