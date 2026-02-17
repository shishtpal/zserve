import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Local Server',
  description: 'A lightweight HTTP file server written in Zig',
  lang: 'en-US',

  base: '/zserve/',

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/logo.svg' }]
  ],

  themeConfig: {
    logo: '/logo.svg',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'API', link: '/guide/api' }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Guide',
          items: [
            { text: 'Getting Started', link: '/guide/getting-started' },
            { text: 'Configuration', link: '/guide/configuration' },
            { text: 'Features', link: '/guide/features' },
            { text: 'HTTP API', link: '/guide/api' }
          ]
        },
        {
          text: 'Advanced',
          items: [
            { text: 'Security', link: '/guide/security' },
            { text: 'Performance', link: '/guide/performance' }
          ]
        },
        {
          text: 'Project',
          items: [
            { text: 'Roadmap', link: '/guide/roadmap' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/example/local-server' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2026-present'
    },

    search: {
      provider: 'local'
    },

    outline: {
      level: [2, 3]
    }
  }
})
