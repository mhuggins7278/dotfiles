return {
  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'zbirenbaum/copilot.lua' },
    event = 'InsertEnter',
    config = true,
    init = function()
      require('copilot').setup {
        suggestion = {
          enabled = false,
        },
        panel = {
          enabled = false,
        },
      }
    end,
  },
  {
    {
      'CopilotC-Nvim/CopilotChat.nvim',
      -- version = 'v2.11.0',
      build = 'make tiktoken',
      branch = 'main',
      -- Do not use branch and version together, either use branch or version
      dependencies = {
        { 'nvim-telescope/telescope.nvim' }, -- Use telescope for help actions
        { 'nvim-lua/plenary.nvim' },
      },
      opts = {
        agent = 'copilot', -- Agent to use, 'copilot' or 'openai'
        model = 'o1', -- GPT model to use, 'gpt-3.5-turbo', 'gpt-4', or 'gpt-4o'
        chat_autocomplete = true,
        question_header = ' ',
        answer_header = ' ',
        error_header = '🚨',
        auto_follow_cursor = true, -- Don't follow the cursor after getting response
        auto_insert_mode = true,
        show_help = true, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
        mappings = {
          -- Use tab for completion
          complete = {
            detail = 'Use @<Tab> or /<Tab> for options.',
            insert = '<Tab>',
          },
          -- Close the chat
          close = {
            normal = 'q',
            insert = '<C-c>',
          },
          -- Reset the chat buffer
          reset = {
            normal = '<C-x>',
            insert = '<C-x>',
          },
          -- Submit the prompt to Copilot
          submit_prompt = {
            normal = '<CR>',
            insert = '<C-s>',
          },
          -- Accept the diff
          accept_diff = {
            normal = '<C-y>',
            insert = '<C-y>',
          },
          -- Yank the diff in the response to register
          yank_diff = {
            normal = 'gmy',
          },
          -- Show the diff
          show_diff = {
            normal = 'gmd',
          },
          -- Show the prompt
          show_info = {
            normal = 'gmp',
          },
          -- Show the user selection
          show_context = {
            normal = 'gms',
          },
        },
      },
      config = function(_, opts)
        local chat = require 'CopilotChat'
        local select = require 'CopilotChat.select'
        -- Use unnamed register for the selection
        opts.selection = select.unnamed

        chat.setup(opts)

        vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
          chat.ask(args.args, { selection = select.visual })
        end, { nargs = '*', range = true })

        -- Inline chat with Copilot
        vim.api.nvim_create_user_command('CopilotChatInline', function(args)
          chat.ask(args.args, {
            selection = select.visual,
            window = {
              layout = 'float',
              relative = 'cursor',
              width = 1,
              height = 0.4,
              row = 1,
            },
          })
        end, { nargs = '*', range = true })

        -- Restore CopilotChatBuffer
        vim.api.nvim_create_user_command('CopilotChatBuffer', function(args)
          chat.ask(args.args, { selection = select.buffer })
        end, { nargs = '*', range = true })

        -- Custom buffer for CopilotChat
        vim.api.nvim_create_autocmd('BufEnter', {
          pattern = 'copilot-*',
          callback = function()
            vim.opt_local.relativenumber = true
            vim.opt_local.number = true

            -- Get current filetype and set it to markdown if the current filetype is copilot-chat
            local ft = vim.bo.filetype
            if ft == 'copilot-chat' then
              vim.bo.filetype = 'markdown'
            end
          end,
        })

        -- Add which-key mappings
        local wk = require 'which-key'
        wk.add {
          { '<leader>gm', group = '+Copilot Chat' }, -- group
          { '<leader>gmd', desc = 'Show diff' },
          { '<leader>gmp', desc = 'System prompt' },
          { '<leader>gms', desc = 'Show selection' },
          { '<leader>gmy', desc = 'Yank diff' },
        }
      end,
      event = 'VeryLazy',
      keys = {
        -- Show help actions with telescope
        {
          '<leader>mh',
          function()
            local actions = require 'CopilotChat.actions'
            require('CopilotChat.integrations.telescope').pick(actions.help_actions())
          end,
          desc = 'CopilotChat - Help actions',
        },
        -- Show prompts actions with telescope
        {
          '<leader>mp',
          function()
            local actions = require 'CopilotChat.actions'
            require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
          end,
          desc = 'CopilotChat - Prompt actions',
        },
        {
          '<leader>mp',
          ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
          mode = 'x',
          desc = 'CopilotChat - Prompt actions',
        },
        -- Code related commands
        { '<leader>me', '<cmd>CopilotChatExplain<cr>', desc = 'CopilotChat - Explain code' },
        { '<leader>mt', '<cmd>CopilotChatTests<cr>', desc = 'CopilotChat - Generate tests' },
        { '<leader>mr', '<cmd>CopilotChatReview<cr>', desc = 'CopilotChat - Review code' },
        { '<leader>mR', '<cmd>CopilotChatRefactor<cr>', desc = 'CopilotChat - Refactor code' },
        { '<leader>mn', '<cmd>CopilotChatBetterNamings<cr>', desc = 'CopilotChat - Better Naming' },
        -- Chat with Copilot in visual mode
        {
          '<leader>mv',
          ':CopilotChatVisual<cr>',
          mode = 'x',
          desc = 'CopilotChat - Open in vertical split',
        },
        {
          '<leader>mI',
          '<cmd>CopilotChatInline<cr>',
          desc = 'CopilotChat - Inline chat',
        },
        -- Custom input for CopilotChat
        {
          '<leader>mi',
          function()
            local input = vim.fn.input 'Ask Copilot: '
            if input ~= '' then
              vim.cmd('CopilotChat ' .. input)
            end
          end,
          desc = 'CopilotChat - Ask input',
        },
        -- Generate commit message based on the git diff
        {
          '<leader>mm',
          '<cmd>CopilotChatCommit<cr>',
          desc = 'CopilotChat - Generate commit message for staged changes',
        },
        -- Quick chat with Copilot
        {
          '<leader>mq',
          function()
            local input = vim.fn.input 'Quick Chat: '
            if input ~= '' then
              vim.cmd('CopilotChatBuffer ' .. input)
            end
          end,
          desc = 'CopilotChat - Quick chat',
        },
        -- Debug
        { '<leader>md', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - Debug Info' },
        -- Fix the issue with diagnostic
        { '<leader>mf', '<cmd>CopilotChatFix<cr>', desc = 'CopilotChat - Fix Diagnostic' },
        -- Clear buffer and chat history
        { '<leader>ml', '<cmd>CopilotChatReset<cr>', desc = 'CopilotChat - Clear buffer and chat history' },
        -- Toggle Copilot Chat Vsplit
        { '<leader>mv', '<cmd>CopilotChatToggle<cr>', desc = 'CopilotChat - Toggle' },
        -- Copilot Chat Models
        { '<leader>m?', '<cmd>CopilotChatModels<cr>', desc = 'CopilotChat - Select Models' },
      },
    },
  },
}
