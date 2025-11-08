return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      -- {
      --   dir = "~/github/mhuggins7278/neotest-jest",
      -- },
      'nvim-neotest/nvim-nio', -- Still required for async operations
      'nvim-lua/plenary.nvim',
      -- FixCursorHold.nvim removed - not needed in nvim 0.11+
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-jest',
      'nvim-neotest/neotest-go',
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
        -- Discovery settings - consider enabling for better test detection
        discovery = {
          enabled = false, -- Set to true if you want automatic test discovery
          concurrent = 0, -- 0 = auto-assign workers based on CPU count
          filter_dir = function(name, rel_path, root)
            -- Exclude build directories to prevent treesitter errors
            return name ~= 'node_modules' and name ~= 'dist' and name ~= 'build' and name ~= '.next'
          end,
        },
        -- Output configuration
        output = {
          enabled = true,
          open_on_run = 'short', -- 'short' | true | false - auto-open on test run
        },
        output_panel = {
          enabled = true,
          open = 'botright split | resize 15',
        },
        -- Running configuration
        running = {
          concurrent = true, -- Run tests concurrently when adapter supports it
        },
        -- Summary window settings
        summary = {
          enabled = true,
          animated = true, -- Animate icons in summary window
          follow = true, -- Auto-expand current file
          expand_errors = true, -- Auto-expand failed tests
        },
        -- Status display
        status = {
          enabled = true,
          virtual_text = false, -- Use signs instead of virtual text for better performance
          signs = true,
        },
        -- Diagnostic integration
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },
        -- Test adapters
        adapters = {
          require 'neotest-jest' {
            jestCommand = 'npm test -- --silent=false',
            jest_test_discovery = true,
            env = {},
            cwd = function()
              return vim.fn.getcwd()
            end,
            -- Custom test file matcher to support *.tests.ts pattern
            isTestFile = function(file_path)
              -- Support both standard patterns and *.tests.* pattern
              if not file_path then
                return false
              end
              
              local patterns = {
                '%.test%.%w+$',     -- *.test.js, *.test.ts, etc.
                '%.tests%.%w+$',    -- *.tests.js, *.tests.ts, etc.
                '%.spec%.%w+$',     -- *.spec.js, *.spec.ts, etc.
                '%.specs%.%w+$',    -- *.specs.js, *.specs.ts, etc.
              }
              
              for _, pattern in ipairs(patterns) do
                if file_path:match(pattern) then
                  return true
                end
              end
              
              return false
            end,
          },
          require 'neotest-vitest',
          require 'neotest-go',
        },
      }
    end,
  },
}
