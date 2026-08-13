## 0.1.0

Breaking: the metric tokens are gone. `FlowSpacing` and `FlowRadii` are
removed, along with `FlowTheme.spacing`, `FlowTheme.radii`, and the
`context.flowSpacing` / `context.flowRadii` extensions. Following Material's
structure, each component now bakes its metrics from the Flow UI design file
and exposes per-widget overrides where hosts retheme:

- `FlowComposer.padding` / `FlowComposer.borderRadius`
- `FlowMessage.bubbleRadius` / `FlowMessage.bubblePadding`
- `FlowAttachmentGroup.tileRadius`
- `FlowSuggestion.padding` / `FlowSuggestion.borderRadius`
- `FlowMenuStyle.sheetRadius` (bottom-sheet corners; `menuRadius` covers the
  anchored card)

`FlowTheme` carries colors and typography only. `FlowComposer`'s default
padding is now direction-aware (`EdgeInsetsDirectional`), so RTL layouts
mirror correctly.

Components to date: theme tokens, message & thread, message actions,
streaming text, shimmer text, thinking indicator, composer, model selector,
menu (anchored + bottom sheet), attachments with full-screen preview,
suggestions, and the chat screen surface.

## 0.0.1

Initial scaffold.
