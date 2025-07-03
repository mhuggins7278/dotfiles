return {
  'olimorris/codecompanion.nvim',
  enabled = false,
  opts = {},
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
  },
  config = function()
    require('codecompanion').setup {
      display = {
        action_palette = {
          provider = 'snacks',
        },
      },
      strategies = {
        chat = {
          adapter = 'copilot',
          tools = {
            groups = {
              ['agentic'] = {
                description = 'Agentic coding tool - Can run code, edit code, modify files, call MCP servers',
                system_prompt = "**DO NOT** make any assumptions about the dependencies that a user has installed. If you need to install any dependencies to fulfil the user's request, do so via the Command Runner tool. If the user doesn't specify a path, use their current working directory.",
                tools = {
                  'cmd_runner',
                  'editor',
                  'files',
                  'use_mcp_tool',
                  'access_mcp_resource',
                },
              },
            },
          },
        },
        inline = {
          adapter = 'copilot',
        },
        cmd = {
          adapter = 'copilot',
        },
      },
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
    }
    vim.keymap.set('n', '<leader>at', ':CodeCompanionChat toggle<cr>', { desc = '[T]oggle [A]I Chat' })
    vim.keymap.set('x', '<leader>aa', ':CodeCompanionActions<cr>', { desc = '[A]I [A]ctions' })
  end,
}
