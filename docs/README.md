# flow_ui docs

The documentation site for [flow_ui](https://github.com/StacDev/flow_ui),
built with [Astro Starlight](https://starlight.astro.build).

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # static site in dist/
```

`predev`/`prebuild` copy the package's bundled Figtree faces from the repo's
`fonts/` into `public/fonts/` (gitignored) — repo fonts stay the single
source. Brand colors in `src/styles/theme.css` mirror the package's design
tokens in `lib/src/theme/flow_colors.dart`.

`npm run playground` builds the repo's `playground/` Flutter app for the
web into `public/playground/` — served at `/playground/` and embedded on
component pages as live demos via `src/components/FlowDemo.astro`
(`/playground/?embed=<demo>&variant=<v>&theme=<light|dark>`).
`npm run build:site` chains playground + docs into one `dist/`.

Deploys to Cloudflare Pages from `.github/workflows/publish.yml` — every
release tag ships the site (playground included) alongside the pub.dev
publish, and `workflow_dispatch` redeploys it on its own.

Planned: `dart doc` output under `public/api/`.
