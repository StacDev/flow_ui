// Navigates to the docs site that hosts the playground.
//
// The playground deploys at `/playground/` on the docs origin, so the docs
// live at `/`. Web-only: the conditional import binds the browser call, and
// every other platform gets the no-op (the sidebar hides the link there
// anyway).
export 'open_docs_stub.dart' if (dart.library.js_interop) 'open_docs_web.dart';
