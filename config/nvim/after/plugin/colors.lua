require('rose-pine').setup({
    disable_background = true
})
require("tokyonight").setup({
    transparent = true,
    styles = {
        floats = "transparent"
    }
})
require("catppuccin").setup({
    flavour = "macchiato",
    transparent_background = true,
})

require("kanagawa").setup({
    transparent = true,
})


function ColorMyPencils(color)
    color = color or "catppuccin"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

end

ColorMyPencils()
