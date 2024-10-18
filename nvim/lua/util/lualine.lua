-- Borrowed shamelessley from Lazyvim and then modified
---@class custom.util.lualine
local M = {}

function M.harpoon_status()
  -- only run this if harpoon has been loaded
  local nvim_harpoon_config = require('lazy.core.config').plugins['harpoon']
  if not nvim_harpoon_config or not nvim_harpoon_config._.loaded then return '' end

  local filename = vim.fn.bufname('%')
  local harpoonItem, harpoonIndex = require('harpoon'):list():get_by_value(filename)
  if harpoonItem then return harpoonIndex .. '↾' end
  -- ↼ (LEFTWARDS HARPOON WITH BARB UPWARDS)
  -- ↽ (LEFTWARDS HARPOON WITH BARB DOWNWARDS)
  -- ↾ (UPWARDS HARPOON WITH BARB RIGHTWARDS)
  -- ↿ (UPWARDS HARPOON WITH BARB LEFTWARDS)
  -- ⇀ (RIGHTWARDS HARPOON WITH BARB UPWARDS)
  -- ⇁ (RIGHTWARDS HARPOON WITH BARB DOWNWARDS)
  -- ⇂ (DOWNWARDS HARPOON WITH BARB RIGHTWARDS)
  -- ⇃ (DOWNWARDS HARPOON WITH BARB LEFTWARDS)
  return ''
end

function M.cmp_source(name, icon)
  local started = false
  local function status()
    -- only run this if cmp has been loaded
    local nvim_cmp_config = require('lazy.core.config').plugins['nvim-cmp']
    if not nvim_cmp_config or not nvim_cmp_config._.loaded then return nil end

    for _, s in ipairs(require('cmp').core.sources) do
      if s.name == name then
        if s.source:is_available() then
          started = true
        else
          return started and 'error' or nil
        end
        if s.status == s.SourceStatus.FETCHING then return 'pending' end
        return 'ok'
      end
    end
  end

  local highlighs = {
    ok = 'Special',
    error = 'DiagnosticError',
    pending = 'DiagnosticWarn',
  }

  local colors = {}

  -- We don't use the highlights so it'll match the lualine bg
  for key, hl_name in pairs(highlighs) do
    local hl = vim.api.nvim_get_hl(0, { name = hl_name })
    colors[key] = string.format('#%06x', hl.fg)
  end

  return {
    function()
      return icon -- or LazyVim.config.icons.kinds[name:sub(1, 1):upper() .. name:sub(2)]
    end,

    cond = function() return status() ~= nil end,
    color = function() return { fg = colors[status()] } or { fg = colors.ok } end,
  }
end

---@param component any
---@param text string
---@param hl_group? string
---@return string
function M.format(component, text, hl_group)
  text = text:gsub('%%', '%%%%')
  if not hl_group or hl_group == '' then return text end
  ---@type table<string, string>
  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]
  if not lualine_hl_group then
    local utils = require('lualine.utils.utils')
    ---@type string[]
    local gui = vim.tbl_filter(function(x) return x end, {
      utils.extract_highlight_colors(hl_group, 'bold') and 'bold',
      utils.extract_highlight_colors(hl_group, 'italic') and 'italic',
    })

    lualine_hl_group = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, 'fg'),
      gui = #gui > 0 and table.concat(gui, ',') or nil,
    }, 'LV_' .. hl_group) --[[@as string]]
    component.hl_cache[hl_group] = lualine_hl_group
  end
  return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

---@param opts? {relative: "cwd"|"root", modified_hl: string?, directory_hl: string?, filename_hl: string?, modified_sign: string?, readonly_icon: string?, length: number?}
function M.pretty_path(opts)
  opts = vim.tbl_extend('force', {
    relative = 'cwd',
    modified_hl = 'MatchParen',
    directory_hl = '',
    filename_hl = 'Bold',
    modified_sign = '',
    readonly_icon = ' 󰌾 ',
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand('%:p') --[[@as string]]

    if path == '' then return '' end

    local cwd = vim.uv.fs_realpath(vim.uv.cwd() or '')
    -- local debug = false

    ---@diagnostic disable-next-line: param-type-mismatch
    if opts.relative == 'cwd' and path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    else
      ---@diagnostic disable-next-line: param-type-mismatch
      path = vim.fn.fnamemodify(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)), ':~:.')
    end

    if #path > 40 then
      local Path = require('plenary.path')
      path = tostring(Path:new(path):shorten(1, { -1, -2, -3 }))
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, '[\\/]')
    -- if debug then vim.notify(vim.inspect(parts)) end

    -- if opts.length == 0 then
    --   parts = parts
    -- elseif #parts > opts.length then
    --   parts = { parts[1], '…', unpack(parts, #parts - opts.length + 2, #parts - 1), parts[#parts] }
    -- end

    -- if debug then vim.notify(vim.inspect(parts)) end

    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = parts[#parts] .. opts.modified_sign
      parts[#parts] = M.format(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = M.format(self, parts[#parts], opts.filename_hl)
    end

    local dir = ''
    if #parts > 1 then
      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
      dir = M.format(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ''
    if vim.bo.readonly then readonly = M.format(self, opts.readonly_icon, opts.modified_hl) end
    -- if debug then nvim.notify(dir) end

    local return_path = dir .. parts[#parts] .. readonly

    local harpoonItem, harpoonIndex = require('harpoon'):list():get_by_value(vim.fn.bufname('%'))
    if harpoonItem then
      local harpoonIndexChar = ({ '¹', '²', '³', '⁴', '⁵' })[harpoonIndex]
      -- local harpoonIndexChar = ' '..({ '1', '2', '3', '4', '5' })[harpoonIndex]..'↾'
      return return_path .. harpoonIndexChar
    end

    return return_path
  end
end

return M
