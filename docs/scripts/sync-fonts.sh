#!/usr/bin/env bash
# Copies the package's bundled Figtree faces (the four weights the design
# uses) into the docs site, keeping repo fonts/ the single source. Runs
# automatically via the predev/prebuild npm hooks.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p public/fonts
cp ../fonts/Figtree-Regular.ttf \
   ../fonts/Figtree-Medium.ttf \
   ../fonts/Figtree-SemiBold.ttf \
   ../fonts/Figtree-Bold.ttf \
   ../fonts/OFL.txt \
   public/fonts/
