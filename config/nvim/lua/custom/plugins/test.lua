return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      -- {
      --   dir = "~/github/mhuggins7278/neotest-jest",
      -- },
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-jest',
      'marilari88/neotest-vitest',
    },
    keys = {
      {
        '<leader>tl',
        function()
          require('neotest').run.run_last()
        end,
        desc = 'Run Last Test',
      },
      {
        '<leader>tL',
        function()
          require('neotest').run.run_last { strategy = 'dap' }
        end,
        desc = 'Debug Last Test',
      },
      {
        '<leader>tw',
        function()
          require('neotest').run.run { jestCommand = 'npm run test:watch' }
        end,
        desc = 'Run Watch',
      },
      {
        '<leader>tr',
        function()
          require('neotest').run.run()
        end,
        desc = 'Run Nearest',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Toggle Summary',
      },
      {
        '<leader>to',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = 'Toggle Output Panel',
      },
      {
        '<leader>tc',
        function()
          require('neotest').output_panel.clear()
        end,
        desc = 'Clear Output Panel',
      },
    },
    config = function()
      require('neotest').setup {
        discovery = { enabled = false },
        adapters = {
          require 'neotest-jest' {
            jestCommand = 'npm test -- --silent=false',
            jest_test_discovery = true,
            env = {},
            cwd = function()
              return vim.fn.getcwd()
            end,
          },
          require 'neotest-vitest',
        },
      }
    end,
  },
}
