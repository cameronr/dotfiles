return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'yetone/avante.nvim',
    enabled = false,
    cond = function() return vim.fn.executable('make') == 1 end,
    cmd = 'AvanteToggle',
    keys = {
      { '<leader>aa', '<cmd>AvanteAsk<CR>', desc = 'avante: ask' },
      { '<leader>at', '<cmd>AvanteToggle<CR>', desc = 'avante: toggle' },
    },

    build = 'make',

    opts = {
      -- cursor_applying_provider = 'groq', -- In this example, use Groq for applying, but you can also use any provider you want.
      behaviour = {
        -- enable_cursor_planning_mode = true, -- enable cursor planning mode!
      },

      providers = {
        groq = { -- define groq provider
          __inherited_from = 'openai',
          api_key_name = 'GROQ_API_KEY',
          endpoint = 'https://api.groq.com/openai/v1/',
          model = 'llama-3.3-70b-versatile',
          max_tokens = 32768, -- remember to increase this value, otherwise it will stop generating halfway
        },
      },
      -- provider = 'openai',
      -- openai = {
      --   endpoint = 'https://api.openai.com/v1',
      --   model = 'gpt-4o', -- your desired model (or use gpt-4o, etc.)
      --   timeout = 30000, -- timeout in milliseconds
      --   temperature = 0, -- adjust if needed
      --   max_tokens = 4096,
      --   -- reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
      -- },
    },
  },
  ---@module 'lazy'
  ---@type LazySpec
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = {
      'Kaiser-Yang/blink-cmp-avante',
    },
    opts = {
      sources = {
        -- Add 'avante' to the list
        default = { 'avante' },
        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
      },
    },
  },
}
