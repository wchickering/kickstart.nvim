# Agent Guidelines for Neovim Configuration

## Build/Lint/Test Commands
- **Format Lua**: `stylua .` (configured in .stylua.toml with 2-space indents)
- **Format Python**: `ruff format <file>` (auto-formatted via conform.nvim on save)
- **Health Check**: `:checkhealth` (run inside Neovim to verify configuration)
- **Plugin Management**: `:Lazy` to manage plugins, `:Lazy update` to update all
- **LSP Status**: `:Mason` to view/install language servers and tools

## Code Style Guidelines
- **Indentation**: 2 spaces for Lua (enforced by stylua), follow existing patterns
- **Comments**: Use `--` for Lua comments, no automatic comment generation unless requested
- **Imports**: Use `require()` at top of files, group by plugin/module type
- **Naming**: snake_case for variables/functions, PascalCase for plugin config tables
- **String Style**: Auto-prefer single quotes (stylua configured), use double for interpolation
- **Line Length**: 160 characters max (stylua configured)
- **Function Calls**: No parentheses for single string/table args (stylua configured)

## Plugin Architecture
- Main config in `init.lua`, custom plugins in `lua/custom/plugins/`
- Use lazy.nvim plugin specs: `{ 'plugin/name', opts = {}, config = function() end }`
- Follow existing patterns for keymaps: `vim.keymap.set(mode, key, action, { desc = 'description' })`
- LSP/formatter config via Mason: add tools to `ensure_installed` table in init.lua

## Error Handling
- Use `pcall()` for optional plugin loading: `pcall(require('plugin').load_extension, 'name')`
- Check capabilities before using LSP features: `client_supports_method(client, method, bufnr)`
- Graceful degradation for missing tools (e.g., Nerd Font checks via `vim.g.have_nerd_font`)