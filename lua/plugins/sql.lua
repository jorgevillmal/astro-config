return {

  -- LSP para SQL (sqls)
  {
    "nanotee/sqls.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "sql" },
    config = function()
      require("lspconfig").sqls.setup {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          require("sqls").on_attach(client, bufnr)
        end,
        settings = {
          sqls = { connections = {} },
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

      vim.keymap.set("v", "<leader>qe", ":DB<CR>", { desc = "DB: Ejecutar selección" })
      vim.keymap.set("n", "<leader>ql", ":.DB<CR>", { desc = "DB: Ejecutar línea" })
      vim.keymap.set("n", "<leader>qa", ":%DB<CR>", { desc = "DB: Ejecutar archivo completo" })

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

      -- No bloquear autoformato en SQL
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function(args)
          vim.bo[args.buf].formatexpr = ""
          vim.bo[args.buf].indentexpr = ""
          vim.b[args.buf].autoformat = true
        end,
      })

      -- Commentstring
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql" },
        callback = function(args) vim.bo[args.buf].commentstring = "-- %s" end,
      })
    end,
  },

  -- Conform: encadenar sql-formatter -> sqlfluff
  {
    "stevearc/conform.nvim",
    opts = {
      -- Ejecuta AMBOS en orden: primero sql-formatter, luego sqlfluff
      formatters_by_ft = {
        sql = { "sql_formatter", "sqlfluff" },
      },
      formatters = {
        -- 1) sql-formatter (Node). Asegúrate de tenerlo instalado (npm i -g sql-formatter)
        sql_formatter = {
          command = "sql-formatter",
          args = function()
            local cfg = vim.fn.expand "~/.sql-formatter.json"
            if vim.fn.filereadable(cfg) == 1 then
              return { "--config", cfg }
            else
              return { "--language", "mysql" }
            end
          end,
          stdin = true,
          exit_codes = { 0 }, -- este debería salir 0
        },
        -- 2) sqlfluff (pulido final con tus reglas)
        sqlfluff = {
          command = "sqlfluff",
          args = { "fix", "-", "--dialect", "mysql", "--config", vim.fn.expand "~/.sqlfluff" },
          stdin = true,
          exit_codes = { 0, 1 }, -- 1 = violaciones no corregibles; no lo tratamos como error
          env = { SQLFLUFF_CONFIG = vim.fn.expand "~/.sqlfluff" },
        },
      },
      -- Ejecuta TODOS los formatters listados para el ft (no solo el primero)
      run_all_formatters = true,
      stop_after_first = false,
      notify_on_error = false,
    },
    config = function(_, opts)
      require("conform").setup(opts)
      -- Formatear SIEMPRE al guardar .sql
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.sql",
        callback = function(args)
          require("conform").format {
            bufnr = args.buf,
            lsp_fallback = false,
            timeout_ms = 8000,
          }
        end,
      })
    end,
  },
}
