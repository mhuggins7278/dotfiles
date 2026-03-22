return {
  -- explicitly add default filetypes, so that we can extend
  -- them in related extras
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  settings = {
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
          entriesLimit = 100,
        },
        plugins = {},
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
        autoImports = true,
        paths = true,
        includeCompletionsForImportStatements = true,
      },
      preferences = {
        includePackageJsonAutoImports = 'auto',
        autoImportFileExcludePatterns = {
          '**/node_modules/**',
          '**/.git/**',
          '**/dist/**',
          '**/build/**',
        },
        preferTypeOnlyAutoImports = true,
        renameMatchingJsxTags = true,
        useAliasesForRenames = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
        autoImports = true,
        paths = true,
        includeCompletionsForImportStatements = true,
      },
      preferences = {
        includePackageJsonAutoImports = 'auto',
        autoImportFileExcludePatterns = {
          '**/node_modules/**',
          '**/.git/**',
          '**/dist/**',
          '**/build/**',
        },
        renameMatchingJsxTags = true,
        useAliasesForRenames = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
  },
}
