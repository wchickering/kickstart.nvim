-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,

    config = function()
      require('oil').setup()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  {
    'nvim-telescope/telescope-file-browser.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local telescope = require 'telescope'
      local fb_actions = telescope.extensions.file_browser.actions

      telescope.setup {
        extensions = {
          file_browser = {
            mappings = {
              ['i'] = {
                -- Only override file open, leave directories alone
                ['<C-o>'] = fb_actions.open,
              },
              ['n'] = {
                ['<C-o>'] = fb_actions.open,
              },
            },
          },
        },
      }

      telescope.load_extension 'file_browser'

      -- open file_browser with the path of the current buffer
      vim.keymap.set('n', '<space>fb', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', { desc = '[F]ile [B]rowser' })
    end,
  },
}
