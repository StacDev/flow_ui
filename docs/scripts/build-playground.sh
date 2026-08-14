#!/usr/bin/env bash
# Builds the playground app for the web and stages it into public/playground,
# where `astro build` copies it verbatim into dist — one deploy serves the
# docs at / and the playground (plus the docs' live demo embeds) at
# /playground/.
#
# Default renderer on purpose: the multithreaded wasm build needs COOP/COEP
# headers that would have to apply to every docs page embedding an iframe.
# --pwa-strategy=none: no service worker serving a stale playground.
set -euo pipefail
cd "$(dirname "$0")/.."
(cd ../playground && flutter pub get && flutter build web --release --base-href /playground/ --pwa-strategy=none)
rm -rf public/playground
mkdir -p public
cp -R ../playground/build/web public/playground
