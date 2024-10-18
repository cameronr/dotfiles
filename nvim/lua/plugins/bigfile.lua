return {
  'tapayne88/bigfile.nvim',
  branch = 'byte-filesize',
  -- enabled = false,
  event = { 'BufNewFile', 'BufReadPre' },
  opts = {
    filesize = 1024 * 1024 * 100,
    filesize_unit = 'bytes',
  },
}
