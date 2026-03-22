return {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = {
          '${3rd}/luv/library',
          unpack(vim.api.nvim_get_runtime_file('', true)),
        },
      },
      completion = {
        callSnippet = 'Replace',
      },
      hint = {
        enable = true,
      },
      telemetry = { enable = false },
    },
  },
}
