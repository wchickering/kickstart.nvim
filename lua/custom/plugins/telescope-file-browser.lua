return {
  -- 'nvim-telescope/telescope-file-browser.nvim',
  -- event = 'VimEnter',
  -- dependencies = {
  --   'nvim-telescope/telescope.nvim',
  --   'nvim-lua/plenary.nvim',
  -- },
  -- config = function()
  --   local telescope = require 'telescope'
  --   local fb_actions = telescope.extensions.file_browser.actions

  --   telescope.setup {
  --     extensions = {
  --       file_browser = {
  --         mappings = {
  --           ['i'] = {
  --             -- Only override file open, leave directories alone
  --             ['<C-o>'] = fb_actions.open,
  --           },
  --           ['n'] = {
  --             ['<C-o>'] = fb_actions.open,
  --           },
  --         },
  --       },
  --     },
  --   }

  --   telescope.load_extension 'file_browser'

  --   -- open file_browser with the path of the current buffer
  --   vim.keymap.set('n', '<space>fb', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', { desc = '[F]ile [B]rowser' })
  -- end,
}
