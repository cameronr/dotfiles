return {
  {
    'yetone/avante.nvim',
    cond = function() return vim.fn.executable('make') == 1 and vim.fn.has('nvim-0.10.1') == 1 end,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = 'AvanteToggle',
    keys = {
      { '<leader>cv', '<cmd>AvanteToggle<CR>', desc = 'Avante toggle' },
    },

    version = '*',
    build = 'make',

    opts = {
      -- cursor_applying_provider = 'groq', -- In this example, use Groq for applying, but you can also use any provider you want.
      behaviour = {
        -- enable_cursor_planning_mode = true, -- enable cursor planning mode!
      },

      vendors = {
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
  {
    'Kaiser-Yang/blink-cmp-avante',
    enabled = vim.g.cmp_engine == 'blink' and vim.fn.has('nvim-0.10.1') == 1,
  },
  {
    'saghen/blink.cmp',
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
