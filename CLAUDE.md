# Dotfiles Repository Guidelines

## Commands

### Testing

- Run nearest test: `<leader>tr`
- Run last test: `<leader>tl`
- Debug last test: `<leader>tL`
- Run test in watch mode: `<leader>tw`
- Toggle test summary: `<leader>ts`
- Toggle output panel: `<leader>to`
- Clear output panel: `<leader>tc`

### Formatting

- Format file: Uses conform.nvim with autoformat on save
- Disable autoformat: `FormatDisable`
- Re-enable autoformat: `FormatEnable`

## Coding Style

### Formatting

- Indent: 2 spaces
- Line length: 80 characters max (see colorcolumn)
- No trailing whitespace

### Language-specific Formatters

- JavaScript/TypeScript: prettierd
- HTML/CSS/Vue: prettierd
- JSON/JSONC: jq
- YAML: prettierd
- Markdown: prettierd
- Lua: stylua
- Go: goimports, gofumpt

### Code Conventions

- Use TypeScript with proper types
- Prefer const over let
- Modern ES syntax (arrow functions, destructuring)
- Descriptive variable names
- Comments for complex logic only
- Always include error handling
- Prefer async/await over promises

### AI Coding Assistance

- Use avant.nvim

