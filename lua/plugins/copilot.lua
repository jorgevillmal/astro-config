return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot_active = true -- Bandera para determinar si Copilot está activo

      -- Función para alternar Copilot
      function toggle_copilot()
        if copilot_active then
          -- Desactivar Copilot
          vim.cmd "Copilot disable"
          copilot_active = false
          print "Copilot desactivado"
        else
          -- Activar Copilot
          vim.cmd "Copilot enable"
          copilot_active = true
          print "Copilot activado"
        end
      end

      -- Configuración de Copilot
      require("copilot").setup {
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<C-]>",
            next = "<C-b>",
            prev = "<M-[>",
            dismiss = "<C-\\>",
          },
        },
      }

      -- Mapeo para alternar Copilot con la combinación <Leader>c
      vim.api.nvim_set_keymap("n", "<Leader>ip", ":lua toggle_copilot()<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function() require("copilot_cmp").setup() end,
  },
}
