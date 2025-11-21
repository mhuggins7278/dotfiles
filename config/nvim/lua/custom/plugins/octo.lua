return {
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    cmd = 'Octo',
    config = function()
      require('octo').setup {
        use_local_fs = true, -- use local files on right side of reviews
        default_to_projects_v2 = false, -- use projects v2 for card commands
        picker = 'snacks', -- picker to use for lists (telescope, fzf-lua, or snacks)
        enable_builtin = true, -- shows a list of builtin actions when no action is provided
        default_merge_method = 'merge', -- default merge method (merge, rebase, or squash)
        default_delete_branch = false, -- whether to delete branch when merging PR
        ssh_aliases = {}, -- SSH aliases for custom domains
        users = 'assignable',
        picker_config = {
          use_emojis = false, -- use emojis in pickers (fzf-lua only)
          mappings = {
            open_in_browser = { lhs = '<C-b>', desc = 'open in browser' },
            copy_url = { lhs = '<C-y>', desc = 'copy url to system clipboard' },
            checkout_pr = { lhs = '<C-o>', desc = 'checkout pull request' },
            merge_pr = { lhs = '<C-r>', desc = 'merge pull request' },
          },
        },
        ui = {
          use_signcolumn = false, -- show "modified" marks on sign column
          use_signstatus = true, -- show "modified" marks on status column
        },
        issues = {
          order_by = {
            field = 'CREATED_AT', -- COMMENTS, CREATED_AT, or UPDATED_AT
            direction = 'DESC', -- DESC or ASC
          },
        },
        pull_requests = {
          order_by = {
            field = 'CREATED_AT',
            direction = 'DESC',
          },
          always_select_remote_on_create = false, -- always prompt for remote repo when creating PRs
          use_branch_name_as_title = false, -- use branch name as PR title
        },
        file_panel = {
          size = 10, -- changed files panel rows
          use_icons = true, -- use web-devicons in file panel
        },
        mappings = {
          issue = {
            close_issue = { lhs = '<localleader>ic', desc = 'close issue' },
            reopen_issue = { lhs = '<localleader>io', desc = 'reopen issue' },
            list_issues = { lhs = '<localleader>il', desc = 'list open issues on same repo' },
            reload = { lhs = '<C-r>', desc = 'reload issue' },
            open_in_browser = { lhs = '<C-b>', desc = 'open issue in browser' },
            copy_url = { lhs = '<C-y>', desc = 'copy url to system clipboard' },
            add_assignee = { lhs = '<localleader>aa', desc = 'add assignee' },
            remove_assignee = { lhs = '<localleader>ad', desc = 'remove assignee' },
            create_label = { lhs = '<localleader>lc', desc = 'create label' },
            add_label = { lhs = '<localleader>la', desc = 'add label' },
            remove_label = { lhs = '<localleader>ld', desc = 'remove label' },
            goto_issue = { lhs = '<localleader>gi', desc = 'navigate to a local repo issue' },
            add_comment = { lhs = '<localleader>ca', desc = 'add comment' },
            delete_comment = { lhs = '<localleader>cd', desc = 'delete comment' },
            next_comment = { lhs = ']c', desc = 'go to next comment' },
            prev_comment = { lhs = '[c', desc = 'go to previous comment' },
            react_hooray = { lhs = '<localleader>rp', desc = 'add/remove 🎉 reaction' },
            react_heart = { lhs = '<localleader>rh', desc = 'add/remove ❤️ reaction' },
            react_eyes = { lhs = '<localleader>re', desc = 'add/remove 👀 reaction' },
            react_thumbs_up = { lhs = '<localleader>r+', desc = 'add/remove 👍 reaction' },
            react_thumbs_down = { lhs = '<localleader>r-', desc = 'add/remove 👎 reaction' },
            react_rocket = { lhs = '<localleader>rr', desc = 'add/remove 🚀 reaction' },
            react_laugh = { lhs = '<localleader>rl', desc = 'add/remove 😄 reaction' },
            react_confused = { lhs = '<localleader>rc', desc = 'add/remove 😕 reaction' },
          },
          pull_request = {
            checkout_pr = { lhs = '<localleader>po', desc = 'checkout PR' },
            merge_pr = { lhs = '<localleader>pm', desc = 'merge commit PR' },
            squash_and_merge_pr = { lhs = '<localleader>psm', desc = 'squash and merge PR' },
            rebase_and_merge_pr = { lhs = '<localleader>prm', desc = 'rebase and merge PR' },
            list_commits = { lhs = '<localleader>pc', desc = 'list PR commits' },
            list_changed_files = { lhs = '<localleader>pf', desc = 'list PR changed files' },
            show_pr_diff = { lhs = '<localleader>pd', desc = 'show PR diff' },
            add_reviewer = { lhs = '<localleader>va', desc = 'add reviewer' },
            remove_reviewer = { lhs = '<localleader>vd', desc = 'remove reviewer request' },
            close_issue = { lhs = '<localleader>ic', desc = 'close PR' },
            reopen_issue = { lhs = '<localleader>io', desc = 'reopen PR' },
            list_issues = { lhs = '<localleader>il', desc = 'list open issues on same repo' },
            reload = { lhs = '<C-r>', desc = 'reload PR' },
            open_in_browser = { lhs = '<C-b>', desc = 'open PR in browser' },
            copy_url = { lhs = '<C-y>', desc = 'copy url to system clipboard' },
            goto_file = { lhs = 'gf', desc = 'go to file' },
            add_assignee = { lhs = '<localleader>aa', desc = 'add assignee' },
            remove_assignee = { lhs = '<localleader>ad', desc = 'remove assignee' },
            create_label = { lhs = '<localleader>lc', desc = 'create label' },
            add_label = { lhs = '<localleader>la', desc = 'add label' },
            remove_label = { lhs = '<localleader>ld', desc = 'remove label' },
            goto_issue = { lhs = '<localleader>gi', desc = 'navigate to a local repo issue' },
            add_comment = { lhs = '<localleader>ca', desc = 'add comment' },
            delete_comment = { lhs = '<localleader>cd', desc = 'delete comment' },
            next_comment = { lhs = ']c', desc = 'go to next comment' },
            prev_comment = { lhs = '[c', desc = 'go to previous comment' },
            react_hooray = { lhs = '<localleader>rp', desc = 'add/remove 🎉 reaction' },
            react_heart = { lhs = '<localleader>rh', desc = 'add/remove ❤️ reaction' },
            react_eyes = { lhs = '<localleader>re', desc = 'add/remove 👀 reaction' },
            react_thumbs_up = { lhs = '<localleader>r+', desc = 'add/remove 👍 reaction' },
            react_thumbs_down = { lhs = '<localleader>r-', desc = 'add/remove 👎 reaction' },
            react_rocket = { lhs = '<localleader>rr', desc = 'add/remove 🚀 reaction' },
            react_laugh = { lhs = '<localleader>rl', desc = 'add/remove 😄 reaction' },
            react_confused = { lhs = '<localleader>rc', desc = 'add/remove 😕 reaction' },
          },
          review_thread = {
            goto_issue = { lhs = '<localleader>gi', desc = 'navigate to a local repo issue' },
            add_comment = { lhs = '<localleader>ca', desc = 'add comment' },
            add_suggestion = { lhs = '<localleader>sa', desc = 'add suggestion' },
            delete_comment = { lhs = '<localleader>cd', desc = 'delete comment' },
            next_comment = { lhs = ']c', desc = 'go to next comment' },
            prev_comment = { lhs = '[c', desc = 'go to previous comment' },
            select_next_entry = { lhs = ']q', desc = 'move to previous changed file' },
            select_prev_entry = { lhs = '[q', desc = 'move to next changed file' },
            select_first_entry = { lhs = '[Q', desc = 'move to first changed file' },
            select_last_entry = { lhs = ']Q', desc = 'move to last changed file' },
            close_review_tab = { lhs = '<C-c>', desc = 'close review tab' },
            react_hooray = { lhs = '<localleader>rp', desc = 'add/remove 🎉 reaction' },
            react_heart = { lhs = '<localleader>rh', desc = 'add/remove ❤️ reaction' },
            react_eyes = { lhs = '<localleader>re', desc = 'add/remove 👀 reaction' },
            react_thumbs_up = { lhs = '<localleader>r+', desc = 'add/remove 👍 reaction' },
            react_thumbs_down = { lhs = '<localleader>r-', desc = 'add/remove 👎 reaction' },
            react_rocket = { lhs = '<localleader>rr', desc = 'add/remove 🚀 reaction' },
            react_laugh = { lhs = '<localleader>rl', desc = 'add/remove 😄 reaction' },
            react_confused = { lhs = '<localleader>rc', desc = 'add/remove 😕 reaction' },
          },
          submit_win = {
            approve_review = { lhs = '<C-a>', desc = 'approve review', mode = { 'n', 'i' } },
            comment_review = { lhs = '<C-m>', desc = 'comment review', mode = { 'n', 'i' } },
            request_changes = { lhs = '<C-r>', desc = 'request changes review', mode = { 'n', 'i' } },
            close_review_tab = { lhs = '<C-c>', desc = 'close review tab', mode = { 'n', 'i' } },
          },
          review_diff = {
            add_review_comment = { lhs = '<localleader>ca', desc = 'add a new review comment', mode = { 'n', 'x' } },
            add_review_suggestion = { lhs = '<localleader>sa', desc = 'add a new review suggestion', mode = { 'n', 'x' } },
            focus_files = { lhs = '<localleader>e', desc = 'move focus to changed file panel' },
            toggle_files = { lhs = '<localleader>b', desc = 'hide/show changed files panel' },
            next_thread = { lhs = ']t', desc = 'move to next thread' },
            prev_thread = { lhs = '[t', desc = 'move to previous thread' },
            select_next_entry = { lhs = ']q', desc = 'move to previous changed file' },
            select_prev_entry = { lhs = '[q', desc = 'move to next changed file' },
            select_first_entry = { lhs = '[Q', desc = 'move to first changed file' },
            select_last_entry = { lhs = ']Q', desc = 'move to last changed file' },
            close_review_tab = { lhs = '<C-c>', desc = 'close review tab' },
            toggle_viewed = { lhs = '<localleader><space>', desc = 'toggle viewer viewed state' },
            goto_file = { lhs = 'gf', desc = 'go to file' },
          },
          file_panel = {
            next_entry = { lhs = 'j', desc = 'move to next changed file' },
            prev_entry = { lhs = 'k', desc = 'move to previous changed file' },
            select_entry = { lhs = '<cr>', desc = 'show selected changed file diffs' },
            refresh_files = { lhs = 'R', desc = 'refresh changed files panel' },
            focus_files = { lhs = '<localleader>e', desc = 'move focus to changed file panel' },
            toggle_files = { lhs = '<localleader>b', desc = 'hide/show changed files panel' },
            select_next_entry = { lhs = ']q', desc = 'move to previous changed file' },
            select_prev_entry = { lhs = '[q', desc = 'move to next changed file' },
            select_first_entry = { lhs = '[Q', desc = 'move to first changed file' },
            select_last_entry = { lhs = ']Q', desc = 'move to last changed file' },
            close_review_tab = { lhs = '<C-c>', desc = 'close review tab' },
            toggle_viewed = { lhs = '<localleader><space>', desc = 'toggle viewer viewed state' },
          },
        },
      }
    end,
  },
  {
    vim.treesitter.language.register('markdown', 'octo'),
  },
}
