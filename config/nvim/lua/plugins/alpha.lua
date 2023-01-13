-- Set header


return {
    'goolord/alpha-nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons'
    },
    config = function()
        local alpha = require('alpha')
        local dashboard = require('alpha.themes.dashboard')

        dashboard.section.header.val = {
            "                                                     ",
            "                                                     ",
            "                                                     ",
            "                                                     ",
            "                                                     ",
            "                                                     ",
            "                                                     ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
            "                                                     ",
        }

        -- Set menu
        dashboard.section.buttons.val = {
            dashboard.button("e", "   New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "   Find file", ":cd $HOME/Workspace | Telescope find_files<CR>"),
            dashboard.button("p", "   Projects", ":Telescope projects<CR>"),
            dashboard.button("r", "   Recent", ":Telescope oldfiles<CR>"),
            dashboard.button("s", "   Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
            dashboard.button("q", "   Quit NVIM", ":qa<CR>"),
        }
        local  stats = require("lazy").stats()
        local function footer()
            local total_plugins = stats.count
            local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
            local version = vim.version()
            local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

            return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version_info
        end

        dashboard.section.footer.val = footer()

        alpha.setup(dashboard.opts)
        vim.keymap.set("n", "<leader>;", ":Alpha<CR>", { desc = "Open Alpha" })
        --Disable folding on alpha buffer
        vim.cmd([[
           autocmd FileType alpha setlocal nofoldenable
        ]])

    end
}
