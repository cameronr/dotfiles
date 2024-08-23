-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  enabled = false,
  -- Optional dependency
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    npairs = require('nvim-autopairs')

    npairs.setup({
      -- The string you provided appears to be a pattern or sequence of characters enclosed within [=[[ and ]]=].
      -- This syntax is used in Lua to create long string literals that can span multiple lines.
      -- Here's what the pattern [=[[%w%%%'%[%"%.%%$]]=]` represents:
      --
      -- %w matches any alphanumeric character (letters and digits) and underscore.
      -- %% matches a literal percent sign %.
      -- %' matches a literal single quote '.
      -- %[ matches a literal opening square bracket [.
      -- %" matches a literal double quote ".
      -- %. matches a literal period or dot ..
      -- %`` matches a literal backtick `` ``.
      -- %$ matches a literal dollar sign $.
      --
      -- So, this pattern would match any string that contains alphanumeric characters, underscores, percent signs,
      -- single quotes, square brackets, double quotes, periods, backticks, and dollar signs.
      -- ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=]

      -- Add { and ( to the list so it won't add the pair when we're adding a function around
      -- existing text
      ignored_next_char = [=[[%w%%%'%[%"%.%`%$%{%(]]=],
      fast_wrap = {},
      check_ts = true,
      ts_config = {
        lua = { 'string' }, -- it will not add a pair on that treesitter node
        javascript = { 'template_string' },
        java = false, -- don't check treesitter on java
      },
    })
    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    vim.notify(vim.inspect(npairs.get_rules('"')))

    npairs.remove_rule('`')
    npairs.add_rule(Rule('`', '`'):with_pair(cond.not_before_regex('[%w%p]')))
  end,
}
