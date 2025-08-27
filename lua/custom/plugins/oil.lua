return {
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
    -- Track current mode: 'float' or 'window'
    local oil_mode = 'float'
    local original_tab = nil
    local original_win = nil

    require('oil').setup {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name, _)
          return name == '..'
        end,
      },
      float = {
        -- Override the default window sizing and positioning.
        override = function(conf)
          -- Get the available screen size
          local screen_h = vim.o.lines
          local screen_w = vim.o.columns

          -- Calculate content height based on current directory
          local cwd = vim.fn.getcwd()
          local entries = vim.fn.readdir(cwd)
          local content_height = math.max(#entries + 5, 10) -- +5 for header/padding, min 10

          -- Calculate max dimensions
          local max_height = math.min(content_height, math.floor(screen_h * 0.8))
          local max_width = math.min(80, math.floor(screen_w * 0.8))

          -- Update the configuration with calculated dimensions
          conf.height = max_height
          conf.width = max_width
          conf.row = math.floor((screen_h - max_height) / 2)
          conf.col = math.floor((screen_w - max_width) / 2)

          return conf
        end,
        border = 'rounded',
        win_options = {
          winblend = 15,
        },
      },
      keymaps = {
        ["<C-f>"] = {
          callback = function()
            local current_mode = oil_mode
            -- Get current oil directory before switching
            local current_oil_dir = vim.api.nvim_buf_get_name(0):match('oil://(.+)')

            -- Toggle mode first
            oil_mode = oil_mode == 'float' and 'window' or 'float'

            if current_mode == 'float' then
              -- Switch from float to window mode: open in new tab
              vim.cmd('quit') -- close floating window
              original_tab = vim.api.nvim_get_current_tabpage()
              original_win = vim.api.nvim_get_current_win()
              vim.cmd('tabnew') -- create new tab for oil
              if current_oil_dir then
                require('oil').open(current_oil_dir)
              else
                require('oil').open()
              end
            else
              -- Switch from window to float mode: close tab and open float
              vim.cmd('tabclose') -- close oil tab, returns to original
              if current_oil_dir then
                require('oil').open_float(current_oil_dir)
              else
                require('oil').open_float()
              end
              original_tab = nil
              original_win = nil
            end
          end,
          desc = "Toggle between floating and full window mode",
        },
        ["<C-p>"] = {
          callback = function()
            if oil_mode == 'float' then
              -- Switch to window mode first
              vim.cmd('quit')
              original_tab = vim.api.nvim_get_current_tabpage()
              original_win = vim.api.nvim_get_current_win()
              oil_mode = 'window'
              vim.cmd('tabnew')
              require('oil').open()
              -- Wait a moment then trigger preview
              vim.schedule(function()
                require('oil.actions').preview.callback()
              end)
            else
              -- Already in window mode, just preview
              require('oil.actions').preview.callback()
            end
          end,
          desc = "Preview (switch to window mode first if in float mode)",
        },
        -- Custom select action to open files in original tab when in window mode
        ["<CR>"] = {
          callback = function()
            if oil_mode == 'window' and original_tab and original_win then
              -- Get the selected file path
              local entry = require('oil').get_cursor_entry()
              if entry and entry.type == 'file' then
                local oil_dir = require('oil').get_current_dir()
                local file_path = oil_dir .. entry.name

                -- Switch to original tab and window
                vim.api.nvim_set_current_tabpage(original_tab)
                if vim.api.nvim_win_is_valid(original_win) then
                  vim.api.nvim_set_current_win(original_win)
                end

                -- Close oil tab
                vim.cmd('tabclose ' .. vim.api.nvim_tabpage_get_number(vim.api.nvim_get_current_tabpage()) + 1)

                -- Open the file
                vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

                -- Reset mode and tracking
                oil_mode = 'float'
                original_tab = nil
                original_win = nil
              else
                -- Not a file, use default oil behavior (navigate directory)
                require('oil.actions').select.callback()
              end
            else
              -- In float mode or no original tab, use default behavior
              require('oil.actions').select.callback()
            end
          end,
          desc = "Open file in original window or navigate directory",
        },
      },
    }

    vim.keymap.set('n', '-', function()
      if oil_mode == 'float' then
        require('oil').open_float()
      else
        -- In window mode, oil is in a separate tab, so just open normally
        require('oil').open()
      end
    end, { desc = 'Open parent directory' })

    -- Reset to float mode when oil tab is closed
    vim.api.nvim_create_autocmd('TabClosed', {
      callback = function()
        -- If we were in window mode, reset to float mode
        if oil_mode == 'window' then
          oil_mode = 'float'
          original_tab = nil
          original_win = nil
        end
      end,
    })

    -- Auto-resize oil floating window when directory changes
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
      pattern = 'oil://*',
      callback = function()
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_config(win).relative ~= '' then -- Only for floating windows
          local oil_url = vim.api.nvim_buf_get_name(0)
          local path = oil_url:match('oil://(.+)')
          if path then
            local entries = vim.fn.readdir(path)
            local content_height = math.max(#entries + 5, 10)
            local screen_h = vim.o.lines
            local screen_w = vim.o.columns
            local max_height = math.min(content_height, math.floor(screen_h * 0.8))
            local max_width = math.min(80, math.floor(screen_w * 0.8))

            local current_config = vim.api.nvim_win_get_config(win)
            current_config.height = max_height
            current_config.width = max_width
            current_config.row = math.floor((screen_h - max_height) / 2)
            current_config.col = math.floor((screen_w - max_width) / 2)
            vim.api.nvim_win_set_config(win, current_config)
          end
        end
      end,
    })
  end,
}
