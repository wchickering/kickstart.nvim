return {
  'LukasPietzschmann/telescope-tabs',
  config = function()
    require('telescope').load_extension 'telescope-tabs'
    require('telescope-tabs').setup {
      -- Your custom config :^)
    }

    vim.keymap.set('n', '<space>st', ':Telescope telescope-tabs list_tabs<CR>', { desc = '[S]earch [T]abs' })
  end,
  dependencies = { 'nvim-telescope/telescope.nvim' },
}
