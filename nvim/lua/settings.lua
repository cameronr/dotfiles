---@class dotfiles.Settings
---@field icons dotfiles.Settings.Icons
---@field transform fun(tbl: table, lower_case?: boolean): table

---@class dotfiles.Settings.Icons
---@field diagnostics table<string, string>
---@field dap table<string, any>
---@field kinds table<string, string>

---@type dotfiles.Settings
---@diagnostic disable-next-line: missing-fields
local M = {}

M.icons = {
  diagnostics = {
    Error = ' ',
    Warn = ' ',
    Info = ' ',
    Hint = ' ',
  },
  dap = {
    Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
    Breakpoint = ' ',
    BreakpointCondition = ' ',
    BreakpointRejected = { ' ', 'DiagnosticError' },
    LogPoint = '.>',
  },
  kinds = {
    Array = ' ',
    Boolean = '󰨙 ',
    Class = ' ',
    Codeium = '󰘦 ',
    Color = ' ',
    Control = ' ',
    Collapsed = ' ',
    Constant = '󰏿 ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = '󰊕 ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = '󰊕 ',
    Module = ' ',
    Namespace = '󰦮 ',
    Null = ' ',
    Number = '󰎠 ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = '󱄽 ',
    String = ' ',
    Struct = '󰆼 ',
    Supermaven = ' ',
    TabNine = '󰏚 ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = '󰀫 ',
  },
}

---Transform table keys to lower case
---@param tbl table Table to transform
---@param lower_case? boolean If true, transform keys to lower case
---@return table
function M.transform(tbl, lower_case)
  local new_tbl = {}
  for k, v in pairs(tbl) do
    local key = lower_case and string.lower(k) or k
    local val = v

    new_tbl[key] = val
  end
  return new_tbl
end

return M
