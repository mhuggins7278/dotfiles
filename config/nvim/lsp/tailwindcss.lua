return {
  root_markers = {
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'tailwind.config.ts',
    'postcss.config.js',
    'postcss.config.ts',
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        typescript = 'javascript',
        typescriptreact = 'javascript',
        ['typescript.tsx'] = 'typescriptreact',
        ['javascript.jsx'] = 'javascriptreact',
      },
      experimental = {
        classRegex = {
          'tw`([^`]*)',
          'tw="([^"]*)',
          'tw={"([^"}]*)',
          'tw\\.\\w+`([^`]*)',
          { 'clsx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { 'classnames\\(([^)]*)\\)', "'([^']*)'" },
          { 'cva\\(([^)]*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
        },
      },
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidConfigPath = 'error',
        invalidScreen = 'error',
        invalidTailwindDirective = 'error',
        invalidVariant = 'error',
        recommendedVariantOrder = 'warning',
      },
      validate = true,
      colorDecorators = true,
      suggestions = true,
      showPixelEquivalents = true,
      rootFontSize = 16,
    },
  },
}
