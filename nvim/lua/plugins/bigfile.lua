return {
  'LunarVim/bigfile.nvim',
  -- enabled = false,
  event = { 'BufNewFile', 'BufReadPre' },
  opts = {
    filesize = 1,
    pattern = function(bufnr, _)
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      local line_count = vim.api.nvim_buf_line_count(bufnr)

      if ok and stats then
        if stats.size > 1024 * 512 then
          vim.notify('Bigfile detected')
          return true
        elseif (stats.size > (10 * 1024)) and (stats.size / line_count) > 250 then
          vim.notify('Long lines detected, bytes: ' .. stats.size .. ', lines: ' .. line_count .. ', bytes / lines: ' .. math.floor(stats.size / line_count))
          vim.b[bufnr].trouble_lualine = false
          return true
        end
      end
      return false
    end,
  },
}
