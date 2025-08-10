return {

  -- LSP para SQL (sqls)
  {
    "nanotee/sqls.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "sql" },
    config = function()
      require("lspconfig").sqls.setup {
        on_attach = function(client, bufnr)
          -- Evitar choques con Conform: desactiva formateo del LSP
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          require("sqls").on_attach(client, bufnr)
          -- Si usas ~/.my.cnf, no pongas credenciales aquí.
          -- vim.cmd [[ let b:db = 'mysql://root@localhost' ]]
        end,
        settings = {
          sqls = {
            connections = {
              -- Déjalo vacío si usas ~/.my.cnf
              -- { driver = "mysql", dataSourceName = "root@tcp(127.0.0.1:3306)/" },
            },
          },
        },
      }
    end,
  },

  -- Dadbod (motor)
  { "tpope/vim-dadbod", lazy = false },

  -- UI de Dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath "data" .. "/db_ui"
      vim.keymap.set("n", "<leader>qd", ":DBUI<CR>", { desc = "DB: Abrir UI" })
      vim.keymap.set("n", "<leader>qq", ":DBUIToggle<CR>", { desc = "DB: Toggle UI" })
    end,
  },

  -- Autocompletado (nvim-cmp + Dadbod) + ejecución por celdas
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql" },
    config = function()
      -- Integración con nvim-cmp en buffers SQL
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql" },
        callback = function()
          local ok, cmp = pcall(require, "cmp")
          if ok then
            cmp.setup.buffer {
              sources = {
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
                { name = "path" },
              },
            }
          end
        end,
      })

      -- Ejecutar selección / línea / archivo
      vim.keymap.set("v", "<leader>qe", ":DB<CR>", { desc = "DB: Ejecutar selección" })
      vim.keymap.set("n", "<leader>ql", ":.DB<CR>", { desc = "DB: Ejecutar línea" })
      vim.keymap.set("n", "<leader>qa", ":%DB<CR>", { desc = "DB: Ejecutar archivo completo" })

      -- Ejecutar celda '-- %%'
      local function run_sql_cell()
        local cur = vim.api.nvim_win_get_cursor(0)[1]
        local last = vim.fn.line "$"
        local function up(line)
          for l = line, 1, -1 do
            if vim.fn.getline(l):match "^%s*%-%-%s*%%" then return l + 1 end
          end
          return 1
        end
        local function down(line)
          for l = line + 1, last do
            if vim.fn.getline(l):match "^%s*%-%-%s*%%" then return l - 1 end
          end
          return last
        end
        local srow, erow = up(cur), down(cur)
        if srow <= erow then vim.cmd(string.format("%d,%dDB", srow, erow)) end
      end
      vim.keymap.set("n", "<leader>qc", run_sql_cell, { desc = "DB: Ejecutar celda (-- %%)" })

      -- 🔒 Desactivar cualquier autoformat genérico en SQL (Conform se encargará)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function(args)
          vim.bo[args.buf].formatexpr = ""
          vim.bo[args.buf].indentexpr = ""
          vim.b[args.buf].autoformat = false
        end,
      })
    end,
  },

  -- Formateo (Conform): SOLO sql-formatter al guardar
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "sql_formatter" },
      },
      formatters = {
        sql_formatter = {
          command = "sql-formatter",
          -- Usa config global (~/.sql-formatter.json) si existe; si no, fija lenguaje
          args = function()
            local cfg = vim.fn.expand "~/.sql-formatter.json"
            if vim.fn.filereadable(cfg) == 1 then
              return { "--config", cfg }
            else
              return { "--language", "mysql" }
            end
          end,
          stdin = true,
        },
      },
      stop_after_first = true, -- no encadenar otros formateadores
      -- No hacer fallback al LSP; solo sql-formatter
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "sql" then return { lsp_fallback = false, timeout_ms = 3000 } end
      end,
      -- notify_on_error = false, -- descomenta si quieres silenciar popups en errores
    },
  },
}
