return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"
    opts = opts or {}

    -- === Fuentes que SÍ queremos en null-ls (nada de SQL aquí) ===
    opts.sources = require("astrocore").list_insert_unique(opts.sources or {}, {
      null_ls.builtins.formatting.stylua, -- Lua
      null_ls.builtins.formatting.prettier, -- JS/TS/JSON/MD, etc.
    })

    -- 🚫 Filtra proactivamente cualquier fuente que toque SQL/MySQL
    opts.sources = vim.tbl_filter(function(src)
      local fts = src.filetypes or (src._opts and src._opts.filetypes) or {}
      for _, ft in ipairs(fts) do
        if ft == "sql" or ft == "mysql" then return false end
      end
      return true
    end, opts.sources)

    -- === Registrar latexindent (una sola vez y si existe el binario) ===
    if vim.fn.executable "/usr/local/bin/latexindent" == 1 and not vim.g.__latexindent_registered then
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
      vim.g.__latexindent_registered = true
    end

    -- ❌ Nunca adjuntar null-ls a buffers SQL/MySQL
    local prev_should_attach = opts.should_attach
    opts.should_attach = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      if ft == "sql" or ft == "mysql" then return false end
      return prev_should_attach and prev_should_attach(bufnr) or true
    end

    -- 🧯 Por si algo lo adjunta igual, detener el cliente en SQL
    local prev_on_attach = opts.on_attach
    opts.on_attach = function(client, bufnr)
      if prev_on_attach then pcall(prev_on_attach, client, bufnr) end
      local ft = vim.bo[bufnr].filetype
      if ft == "sql" or ft == "mysql" then
        client.stop()
        return
      end
    end

    return opts
  end,
}
