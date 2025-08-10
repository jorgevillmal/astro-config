return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"

    opts = opts or {}
    -- Conserva tus fuentes actuales y añade/ordena de forma segura
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.formatting.stylua, -- Lua
      null_ls.builtins.formatting.prettier, -- JS/JSON/MD, etc.
    })

    -- === Configuración manual para latexindent (la mantengo tal cual) ===
    null_ls.register {
      name = "latexindent",
      method = null_ls.methods.FORMATTING,
      filetypes = { "tex", "plaintext", "bib" },
      generator = null_ls.generator {
        command = "/usr/local/bin/latexindent",
        args = { "-m", "-l" },
        to_stdin = true,
      },
    }

    -- === DESACTIVAR formateo de null-ls SOLO para SQL ===
    local prev_on_attach = opts.on_attach
    opts.on_attach = function(client, bufnr)
      if prev_on_attach then pcall(prev_on_attach, client, bufnr) end
      if vim.bo[bufnr].filetype == "sql" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end

    return opts
  end,
}
