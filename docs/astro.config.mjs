// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

/** Dev-only: serve /playground/ from public/playground/index.html. Real
 * static hosts (and the production deploy) resolve directory indexes
 * themselves; Astro's dev server does not. */
const playgroundDevIndex = {
	name: 'playground-dev-index',
	hooks: {
		/** @param {{ server: import('vite').ViteDevServer }} ctx */
		'astro:server:setup'({ server }) {
			server.middlewares.use((req, _res, next) => {
				if (req.url === '/playground' || req.url === '/playground/') {
					req.url = '/playground/index.html';
				} else if (req.url?.startsWith('/playground/?')) {
					req.url = req.url.replace('/playground/?', '/playground/index.html?');
				}
				next();
			});
		},
	},
};

// https://astro.build/config
export default defineConfig({
	// Placeholder until a custom domain is decided.
	site: 'https://flow-ui-docs.pages.dev',
	integrations: [
		playgroundDevIndex,
		starlight({
			title: 'Flow UI',
			description:
				'Flow UI is an open-source Flutter UI library to build production-grade Chat & AI assistant interfaces.',
			customCss: ['./src/styles/theme.css'],
			logo: { src: './src/assets/flow-ui-logo.svg', alt: '' },
			components: {
				PageTitle: './src/components/PageTitle.astro',
				ThemeSelect: './src/components/ThemeSelect.astro',
				// Stock provider with the auto fallback flipped to light for
				// browsers that don't support prefers-color-scheme.
				ThemeProvider: './src/components/ThemeProvider.astro',
			},
			expressiveCode: {
				styleOverrides: {
					borderRadius: '0.75rem',
					borderColor: 'var(--sl-color-hairline-light)',
					codeBackground: 'var(--flow-card)',
					codeFontSize: '0.8125rem',
					frames: {
						shadowColor: 'transparent',
						editorTabBarBackground: 'var(--flow-panel)',
						editorTabBarBorderBottomColor: 'var(--sl-color-hairline-light)',
						editorActiveTabBackground: 'transparent',
						editorActiveTabForeground: 'var(--sl-color-gray-2)',
						editorActiveTabIndicatorTopColor: 'transparent',
						editorActiveTabIndicatorBottomColor: 'var(--sl-color-accent)',
						editorBackground: 'var(--flow-card)',
						terminalBackground: 'var(--flow-card)',
						terminalTitlebarBackground: 'var(--flow-panel)',
						terminalTitlebarBorderBottomColor: 'var(--sl-color-hairline-light)',
						terminalTitlebarForeground: 'var(--sl-color-gray-3)',
					},
				},
			},
			social: [
				{
					icon: 'rocket',
					label: 'Playground',
					href: '/playground/',
				},
				{
					icon: 'seti:dart',
					label: 'pub.dev',
					href: 'https://pub.dev/packages/flow_ui',
				},
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/StacDev/flow_ui',
				},
			],
			editLink: {
				baseUrl: 'https://github.com/StacDev/flow_ui/edit/main/docs/',
			},
			sidebar: [
				{
					label: 'Start here',
					items: ['getting-started', 'theming'],
				},
				{
					label: 'Components',
					items: [{ autogenerate: { directory: 'components' } }],
				},
				{ label: 'Roadmap', slug: 'roadmap' },
			],
		}),
	],
});
