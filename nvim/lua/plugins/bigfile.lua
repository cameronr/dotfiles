return {
  'LunarVim/bigfile.nvim',
  -- enabled = false,
  event = { 'BufNewFile', 'BufReadPre' },
  opts = {
    filesize = 1,
    pattern = function(bufnr, _)
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      ---@diagnostic disable-next-line: undefined-field
      local ok, stats = pcall(vim.loop.fs_stat, buf_name)
      -- local line_count = vim.api.nvim_buf_line_count(bufnr)
      if not ok or not stats then return false end

      if stats.size > 1024 * 512 then
        vim.notify('Bigfile detected')
        return true
      else
        local cmd = string.format("wc -l '%s'", buf_name)
        local output = vim.fn.system(cmd)
        local line_count = tonumber(output:match('^%s*(%d+)'))

        if not line_count or line_count == 0 then return false end

        if (stats.size > (10 * 1024)) and (stats.size / line_count) > 250 then
          vim.notify('Long lines detected, bytes: ' .. stats.size .. ', lines: ' .. line_count .. ', bytes / lines: ' .. math.floor(stats.size / line_count))
          vim.b[bufnr].trouble_lualine = false
          return true
        end
      end
      return false
    end,
  },
}
