return {
  'nvzone/typr',
  dependencies = 'nvzone/volt',
  opts = {},
  cmd = { 'Typr', 'TyprStats' },
  config = function()
    -- Patch loadstring issue before plugin loads
    if not loadstring then
      _G.loadstring = load
    end
    
    -- Patch stats initialization issue
    vim.schedule(function()
      local ok, typr_utils = pcall(require, 'typr.stats.utils')
      if ok then
        local original_save = typr_utils.save
        typr_utils.save = function()
          local state = require('typr.state')
          if not state.data or not state.data.times then
            state.data = typr_utils.gen_default_stats()
          end
          return original_save()
        end
      end
    end)
  end,
}
