lvim.builtin.which_key.mappings["z"] = {
	"<cmd>redir @*> | echon join([expand('%'),  line('.')], ':') | redir END<CR>",
	"Copy file:line",
}

lvim.builtin.which_key.mappings["o"] = {
	name = "Octo",
	i = { "<cmd>Octo issue list glg/Service-Excellence<CR>", "List Issues" },
}
