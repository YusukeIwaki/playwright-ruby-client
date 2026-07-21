/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'playwright-ruby-client',
  tagline: 'Playwright client library for Ruby',
  url: 'https://playwright-ruby-client.vercel.app',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/playwright-logo.svg',
  organizationName: 'YusukeIwaki', // Usually your GitHub org/user name.
  projectName: 'playwright-ruby-client', // Usually your repo name.
  plugins: [
    [
      'docusaurus-plugin-llms',
      {
        generateLLMsTxt: true,
        generateLLMsFullTxt: false,
        generateMarkdownFiles: true,
        docsDir: 'docs',
        title: 'playwright-ruby-client',
        description: 'Ruby client for Playwright, including API reference and integration guides.',
        rootContent: `This is a community-maintained Ruby client for Playwright.

Important usage notes:
- The gem does not include the Playwright driver or its downloader. Install a compatible Playwright package separately and pass its CLI path to \`Playwright.create\`.
- Determine the compatible Playwright version from \`Playwright::COMPATIBLE_PLAYWRIGHT_VERSION\`; do not assume the newest npm package is compatible.
- Use playwright-ruby-client for native Playwright APIs. Use capybara-playwright-driver when compatibility with the Capybara DSL is more important.
- Prefer the Ruby examples and signatures in this documentation over examples for other Playwright language bindings.`,
        includeOrder: [
          'article/getting_started.md',
          'article/guides/**/*.md',
          'api/playwright.md',
          'api/**/*.md',
          'article/api_coverage.mdx',
        ],
        includeUnmatchedLast: true,
        ignoreFiles: ['include/**'],
        excludeImports: true,
        removeDuplicateHeadings: true,
      },
    ],
  ],
  themeConfig: {
    image: 'img/playwright-ruby-client.png',
    navbar: {
      title: 'playwright-ruby-client',
      logo: {
        alt: 'Playwright',
        src: 'img/playwright-logo.svg',
      },
      items: [
        {
          type: 'doc',
          docId: 'article/getting_started',
          position: 'left',
          label: 'Docs',
        },
        {
          type: 'doc',
          docId: 'api/playwright',
          position: 'left',
          label: 'API',
        },
        {
          href: 'https://github.com/YusukeIwaki/playwright-ruby-client',
          'aria-label': 'GitHub',
          className: 'header-github-link',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting started',
              to: '/docs/article/getting_started',
            },
            {
              label: 'API reference',
              to: '/docs/api/playwright',
            },
          ],
        },
        {
          title: 'Source codes',
          items: [
            {
              label: 'playwright-ruby-client',
              to: 'https://github.com/YusukeIwaki/playwright-ruby-client',
            },
            {
              label: 'capybara-playwright-driver',
              to: 'https://github.com/YusukeIwaki/capybara-playwright-driver',
            },
          ],
        },
        {
          title: 'HowTo',
          items: [
            {
              label: 'Develop Playwright driver for Ruby',
              to: 'https://yusukeiwaki.hatenablog.com/entry/2021/01/13/how-to-create-playwright-ruby-client',
            },
            {
              label: 'Implement your own Capybara driver',
              to: 'https://zenn.dev/yusukeiwaki/scraps/280aabf289ae29',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} @YusukeIwaki. <p>Built with <a href="https://docusaurus.io/">Docusaurus</a>.</p>`,
    },
    prism: {
      additionalLanguages: ['bash', 'ruby'],
    },
    algolia: {
      appId: '00PBL1OR8R',
      apiKey: '38d9bd4fef84d709547a1ca466ee8241',
      indexName: 'playwright-ruby-client',
      contextualSearch: false,
    }
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
        },
        blog: {
          feedOptions: {
            type: null,
          },
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
