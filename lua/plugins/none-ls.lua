return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.formatting.stylua, -- Formateador de Lua
      null_ls.builtins.formatting.prettier, -- Formateador de JSON/JS

      -- Configuración manual para latexindent
      null_ls.register {
        name = "latexindent",
        method = null_ls.methods.FORMATTING,
        filetypes = { "tex", "plaintex", "bib" },
        generator = null_ls.generator {
          command = "/usr/local/bin/latexindent",
          args = { "-m", "-l" },
          to_stdin = true,
        },
      },
    })
  end,
}
