return {
  'xixiaofinland/sf.nvim',

  -- Only load when the current working directory contains a .sf/config.json,
  -- which is the Salesforce CLI's project-local config file.
  cond = function()
    return vim.uv.fs_stat(vim.fn.getcwd() .. '/.sf/config.json') ~= nil
  end,

  -- Load after the UI is ready (not ft-gated, so keymaps work for all
  -- filetypes inside the project — LWC, config files, etc.)
  event = 'VeryLazy',

  -- nvim-treesitter is configured separately and provides parser support.
  -- fzf-lua omitted intentionally: metadata browser skipped for now.

  init = function()
    local wk = require 'which-key'
    wk.add {
      { '<leader>F', group = '[F]orce / Salesforce' },
    }
  end,

  config = function()
    require('sf').setup {
      enable_hotkeys = false,
      fetch_org_list_at_nvim_start = true,
    }

    local sf = require 'sf'
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { desc = 'SF: ' .. desc })
    end

    -- Org management
    map('<leader>Fo', sf.set_target_org, '[O]rg: set target')
    map('<leader>FO', sf.fetch_org_list, '[O]rg: refresh list')
    map('<leader>Fw', sf.org_open_current_file, 'Open current file in [W]eb org')

    -- Push / retrieve
    map('<leader>Fp', sf.save_and_push, '[P]ush current file')
    map('<leader>Fr', sf.retrieve, '[R]etrieve current file')
    map('<leader>FP', sf.push_delta, '[P]ush delta (full project)')
    map('<leader>FR', sf.retrieve_delta, '[R]etrieve delta (full project)')

    -- Diff
    map('<leader>Fd', sf.diff_in_target_org, '[D]iff local vs org')

    -- Apex test
    map('<leader>Ft', sf.run_current_test, '[T]est: run current')
    map('<leader>FT', sf.run_all_tests_in_this_file, '[T]est: run all in file')
    map('<leader>Fc', sf.run_current_test_with_coverage, '[C]overage: run current test')
    map('<leader>FC', sf.run_all_tests_in_this_file_with_coverage, '[C]overage: run all in file')
    map('<leader>FL', sf.repeat_last_tests, 'Repeat [L]ast tests')

    -- Coverage sign navigation
    map('<leader>Fs', sf.toggle_sign, 'Toggle coverage [S]igns')
    map(']u', sf.uncovered_jump_forward, 'Next [U]ncovered line')
    map('[u', sf.uncovered_jump_backward, 'Prev [U]ncovered line')

    -- Anonymous Apex
    map('<leader>Fa', sf.run_anonymous, 'Run [A]nonymous Apex (file)')
    map('<leader>FA', sf.run_anonymous_stdin, 'Run [A]nonymous Apex (buffer, no save)')

    -- SOQL
    map('<leader>Fq', sf.run_query, 'Run SO[Q]L query')

    -- Scaffolding
    map('<leader>Fnc', sf.create_apex_class, '[N]ew Apex [C]lass')
    map('<leader>Fnt', sf.create_trigger, '[N]ew [T]rigger')
    map('<leader>Fnl', sf.create_lwc_bundle, '[N]ew [L]WC bundle')

    -- Terminal
    map('<leader>F<space>', sf.toggle_term, 'Toggle SF terminal')
  end,
}
