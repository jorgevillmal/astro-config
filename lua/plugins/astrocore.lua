-- Archivo activado: astrocore.lua

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configuraciones centrales de AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics_mode = 3,
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    options = {
      opt = {
        relativenumber = false,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
      },
      g = {
        -- puedes definir aquí variables globales si es necesario
      },
    },
    mappings = {
      n = {
        -- Navegación entre buffers
        ["]b"] = {
          function() require("astrocore.buffer").nav(vim.v.count1) end,
          desc = "Next buffer",
        },
        ["[b"] = {
          function() require("astrocore.buffer").nav(-vim.v.count1) end,
          desc = "Previous buffer",
        },

        -- Cerrar buffer desde el tabline
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- 🌟 Copilot (sección nueva)
        ["<Leader>i"] = { desc = "Copilot" },
        ["<Leader>it"] = {
          function()
            local active = vim.g.copilot_active or false
            if active then
              vim.cmd "Copilot disable"
              vim.g.copilot_active = false
              vim.notify("Copilot desactivado", vim.log.levels.INFO)
            else
              vim.cmd "Copilot enable"
              vim.g.copilot_active = true
              vim.notify("Copilot activado", vim.log.levels.INFO)
            end
          end,
          desc = "Alternar Copilot",
        },
      },
    },
  },
}
