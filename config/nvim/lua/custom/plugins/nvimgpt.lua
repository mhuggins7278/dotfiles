return {
  'jackMort/ChatGPT.nvim',
  config = function()
    require('chatgpt').setup {
      api_key_cmd = 'security find-generic-password -s NVIM_CHAT_GPT_TOKEN -w',
      max_tokens = 4096,
      openai_params = {
        model = 'gpt-4o-2024-08-06',
        frequency_penalty = 0,
        presence_penalty = 0,
        temperature = 0.2,
        max_tokens = 4096,
        top_p = 0.1,
        n = 1,
      },
      openai_edit_params = {
        model = 'gpt-4o-2024-08-06',
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 4096,
        temperature = 0.2,
        top_p = 0.1,
        n = 1,
      },
    }
  end,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  init = function()
    local wk = require 'which-key'
    wk.add({
      { '<leader>m', group = 'ChatGPT' },
      { '<leader>mc', '<cmd>ChatGPT<CR>', desc = 'ChatGPT' },
      {
        mode = { 'n', 'v' },
        { '<leader>ma', '<cmd>ChatGPTRun add_tests<CR>', desc = 'Add Tests' },
        { '<leader>md', '<cmd>ChatGPTRun docstring<CR>', desc = 'Docstring' },
        { '<leader>me', '<cmd>ChatGPTEditWithInstruction<CR>', desc = 'Edit with instruction' },
        { '<leader>mf', '<cmd>ChatGPTRun fix_bugs<CR>', desc = 'Fix Bugs' },
        { '<leader>mg', '<cmd>ChatGPTRun grammar_correction<CR>', desc = 'Grammar Correction' },
        { '<leader>mk', '<cmd>ChatGPTRun keywords<CR>', desc = 'Keywords' },
        { '<leader>ml', '<cmd>ChatGPTRun code_readability_analysis<CR>', desc = 'Code Readability Analysis' },
        { '<leader>mo', '<cmd>ChatGPTRun optimize_code<CR>', desc = 'Optimize Code' },
        { '<leader>mr', '<cmd>ChatGPTRun roxygen_edit<CR>', desc = 'Roxygen Edit' },
        { '<leader>ms', '<cmd>ChatGPTRun summarize<CR>', desc = 'Summarize' },
        { '<leader>mt', '<cmd>ChatGPTRun translate<CR>', desc = 'Translate' },
        { '<leader>mx', '<cmd>ChatGPTRun explain_code<CR>', desc = 'Explain Code' },
      },
    }, { prefix = '<leader>' })
  end,
}
