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
            accept = "<C-l>",
            next = "<C-j>",
            prev = "<C-k>",
            dismiss = "<C-\\>",
          },
        },
      }
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
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
              local copilot_active = vim.g.copilot_active or false
              if copilot_active then
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
