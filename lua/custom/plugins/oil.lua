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
    local original_buffer = nil

    require('oil').setup {
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

            -- Toggle mode first
            oil_mode = oil_mode == 'float' and 'window' or 'float'

            if current_mode == 'float' then
              -- Close floating window and open in window mode
              vim.cmd('quit')
              original_buffer = vim.api.nvim_get_current_buf()
              require('oil').open()
            else
              -- Close window mode buffer and open in float mode
              if original_buffer and vim.api.nvim_buf_is_valid(original_buffer) then
                vim.api.nvim_set_current_buf(original_buffer)
              end
              original_buffer = nil
              require('oil').open_float()
            end
          end,
          desc = "Toggle between floating and full window mode",
        },
      },
    }

    vim.keymap.set('n', '-', function()
      if oil_mode == 'float' then
        require('oil').open_float()
      else
        -- Store the current buffer before opening oil in full window mode
        original_buffer = vim.api.nvim_get_current_buf()
        require('oil').open()
      end
    end, { desc = 'Open parent directory' })

    -- Restore original buffer when oil is closed (unless a file was selected)
    vim.api.nvim_create_autocmd('BufLeave', {
      pattern = 'oil://*',
      callback = function()
        if oil_mode == 'window' and original_buffer then
          -- Check if we're leaving oil to go to a different buffer (file selection)
          vim.schedule(function()
            local current_buf = vim.api.nvim_get_current_buf()
            local current_buf_name = vim.api.nvim_buf_get_name(current_buf)

            -- If the new buffer is not an oil buffer and not a file we selected from oil,
            -- and if we just closed oil without selecting a file, restore original buffer
            if not current_buf_name:match('^oil://') then
              -- This means we either selected a file or closed oil
              -- We only restore if the window is empty or if we explicitly closed without selection
              local buf_lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
              local is_empty = #buf_lines == 1 and buf_lines[1] == ""

              -- Only restore if buffer is empty (means we closed oil without selecting)
              if is_empty and vim.api.nvim_buf_is_valid(original_buffer) then
                vim.api.nvim_set_current_buf(original_buffer)
              end
              original_buffer = nil
            end
          end)
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
