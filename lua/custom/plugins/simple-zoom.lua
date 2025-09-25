return {
  'fasterius/simple-zoom.nvim',
  opts = {
    hide_tabline = true,
  },
  config = function()
    vim.keymap.set('n', '<leader>z', require('simple-zoom').toggle_zoom, { desc = 'Toggle [Z]oom' })
  end,
}
