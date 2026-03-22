return {
  settings = {
    gopls = {
      gofumpt = true,
      -- Performance optimizations
      diagnosticsDelay = '250ms',
      symbolMatcher = 'FastFuzzy',
      symbolScope = 'workspace',
      -- Completion
      matcher = 'Fuzzy',
      completionBudget = '100ms',
      experimentalPostfixCompletions = true,
      -- Documentation
      linkTarget = 'pkg.go.dev',
      hoverKind = 'FullDocumentation',
      -- Code lenses
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      -- Inlay hints
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      -- Analyses
      analyses = {
        -- fieldalignment removed in gopls v0.17.0, hover over struct fields instead
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedvariable = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules', '-**/node_modules' },
      semanticTokens = true,
    },
  },
}
