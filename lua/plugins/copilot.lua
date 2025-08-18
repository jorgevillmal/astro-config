return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = {
          auto_trigger = true,
          keymap = {
            -- Atajos “oficiales” de copilot.lua
            accept = "<C-l>", -- Mac mini
            next = "<C-j>",
            prev = "<C-k>",
            dismiss = "<C-\\>",
          },
        },
      }

      -- === Alias / atajos alternativos ===
      -- Aceptar también con <C-]> (MacBook)
      local sug = require "copilot.suggestion"
      vim.keymap.set("i", "<C-]>", function()
        if sug.is_visible() then sug.accept() end
      end, { silent = true, desc = "Copilot accept (alt)" })

      -- (Opcional) Si <C-j>/<C-k> chocan con tmux/terminal:
      -- vim.keymap.set("i", "<C-Down>", function() if sug.is_visible() then sug.next() end end, { silent = true })
      -- vim.keymap.set("i", "<C-Up>",   function() if sug.is_visible() then sug.prev() end end, { silent = true })
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" }, -- en lazy.nvim, no uses `after`
    config = function() require("copilot_cmp").setup() end,
  },

  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>i"] = {
          name = "+Copilot",
          t = {
            function()
              local on = vim.g.copilot_active or false
              if on then
                vim.cmd "Copilot disable"
                vim.g.copilot_active = false
                vim.notify "Copilot desactivado"
              else
                vim.cmd "Copilot enable"
                vim.g.copilot_active = true
                vim.notify "Copilot activado"
              end
            end,
            "Toggle Copilot",
          },
        },
      },
    },
  },
}
