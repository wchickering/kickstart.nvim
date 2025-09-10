return {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
    { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
  },
  config = function()
    -- `opencode.nvim` passes options via a global variable instead of `setup()` for faster startup
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      terminal = {
        win = {
          enter = true, -- Always focus the terminal when opened
        },
      },
    }

    -- Required for `opts.auto_reload`
    vim.opt.autoread = true

    -- Recommended keymaps (toggle is defined below with auto-reload setup)
    vim.keymap.set('n', '<leader>oA', function()
      require('opencode').ask()
    end, { desc = 'Ask opencode' })
    vim.keymap.set('n', '<leader>oa', function()
      require('opencode').ask '@cursor: '
    end, { desc = 'Ask opencode about this' })
    vim.keymap.set('v', '<leader>oa', function()
      require('opencode').ask '@selection: '
    end, { desc = 'Ask opencode about selection' })
    vim.keymap.set('n', '<leader>on', function()
      require('opencode').command 'session_new'
    end, { desc = 'New opencode session' })
    vim.keymap.set('n', '<leader>oy', function()
      require('opencode').command 'messages_copy'
    end, { desc = 'Copy last opencode response' })
    vim.keymap.set('n', '<S-C-u>', function()
      require('opencode').command 'messages_half_page_up'
    end, { desc = 'Messages half page up' })
    vim.keymap.set('n', '<S-C-d>', function()
      require('opencode').command 'messages_half_page_down'
    end, { desc = 'Messages half page down' })
    vim.keymap.set({ 'n', 'v' }, '<leader>os', function()
      require('opencode').select()
    end, { desc = 'Select opencode prompt' })

    -- Example: keymap for custom prompt
    vim.keymap.set('n', '<leader>oe', function()
      require('opencode').prompt 'Explain @cursor and its context'
    end, { desc = 'Explain this code' })

    -- Set up auto-reload when terminal is toggled
    local function setup_auto_reload_if_needed()
      -- Check if auto-reload is already set up
      if vim.fn.exists '#OpencodeAutoReload' == 0 then
        require('opencode.server').get_port(function(ok, port)
          if ok then
            require('opencode.reload').setup()
            require('opencode.client').listen_to_sse(port, function(response)
              vim.api.nvim_exec_autocmds('User', {
                pattern = 'OpencodeEvent',
                data = response,
              })
            end)
          end
        end)
      end
    end

    -- Override the toggle keymap to include auto-reload setup
    vim.keymap.set('n', '<leader>ot', function()
      require('opencode').toggle()
      -- Set up auto-reload after a brief delay to let terminal start
      vim.defer_fn(setup_auto_reload_if_needed, 1000)
    end, { desc = 'Toggle opencode' })
  end,
}

