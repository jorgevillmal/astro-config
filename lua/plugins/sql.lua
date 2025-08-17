return {

  -- LSP para SQL (sqls) → raíz como Workbench
  {
    "nanotee/sqls.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "sql" },
    config = function()
      local lsp = require "lspconfig"
      local dsn = os.getenv "SQLS_DSN" or "root@tcp(127.0.0.1:3306)/"
      -- local dsn = os.getenv("SQLS_DSN") or "root@unix(/tmp/mysql.sock)/"

      lsp.sqls.setup {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          require("sqls").on_attach(client, bufnr)
        end,
        settings = {
          sqls = {
            connections = {
              { driver = "mysql", dataSourceName = dsn },
            },
          },
        },
      }
    end,
  },

  -- Dadbod (motor)
  {
    "tpope/vim-dadbod",
    lazy = false,
    init = function()
      vim.g.dbs = {
        root_tcp = "mysql://root@127.0.0.1:3306/",
        -- root_sock = "mysql://root@unix(/tmp/mysql.sock)/",
      }
      vim.g.db = vim.g.dbs.root_tcp

      vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
        pattern = { "sql", "mysql" },
        callback = function(args)
          if (vim.b[args.buf].db or "") == "" then vim.b[args.buf].db = vim.g.db end
        end,
      })
    end,
  },

  -- UI de Dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath "data" .. "/db_ui"
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_show_database_icon = 1

      vim.keymap.set("n", "<leader>qd", ":DBUI<CR>", { desc = "DB: Abrir UI" })
      vim.keymap.set("n", "<leader>qq", ":DBUIToggle<CR>", { desc = "DB: Toggle UI" })
    end,
  },

  -- Autocompletado + ejecución inteligente con bloqueo de contexto
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql" },
    config = function()
      -- nvim-cmp
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

      -----------------------------------------------------------------------
      -- Helpers de BD por buffer + BLOQUEO
      -----------------------------------------------------------------------
      local function _base_url()
        local base = (vim.g.db and type(vim.g.db) == "string") and vim.g.db or ""
        if base == "" then base = (vim.g.dbs and (vim.g.dbs.root_tcp or vim.g.dbs.root_sock)) or "" end
        base = (base or ""):gsub("%s+", "")
        if base == "" then return nil end
        return base:gsub("/+$", "") .. "/"
      end

      local function _with_db(dbname)
        local base = _base_url()
        if not base then
          vim.notify("No hay URL base (g:db o g:dbs.*). Abre :DBUI o revisa tu config.", vim.log.levels.ERROR)
          return nil
        end
        return base .. (dbname or "")
      end

      -- --------- Detector ROBUSTO del último USE real (no comentarios) ---------
      local function _strip_inline_comments(s) return (s or ""):gsub("%-%-.*$", "") end

      local function _find_last_use(before_row)
        local maxrow = vim.fn.line "$"
        local start_row = math.max(1, math.min(before_row or maxrow, maxrow))
        local in_block_comment = false

        for l = start_row, 1, -1 do
          local ln = vim.fn.getline(l)

          if ln:find "%*/" then in_block_comment = false end

          if not in_block_comment then
            local code = _strip_inline_comments(ln)
            -- Sólo aceptamos USE al inicio (tras espacios); evita falsos positivos
            local db = code:match "^%s*[Uu][Ss][Ee]%s+`?([%w_]+)`?%s*;?%s*$"
            if db and db ~= "" then return db end
          end

          if ln:find "/%*" and not ln:find "%*/" then in_block_comment = true end
        end

        return nil
      end
      -- ------------------------------------------------------------------------

      -- Si el buffer está BLOQUEADO, no cambiamos b:db automáticamente
      local function _ensure_db_for_row(row)
        if vim.b.db_lock and (vim.b.db or "") ~= "" then return end
        local db = _find_last_use(row)
        if db then
          local url = _with_db(db)
          if url and vim.b.db ~= url then
            vim.b.db = url
            vim.notify("b:db ← " .. url, vim.log.levels.INFO, { title = "DB context" })
          end
        end
      end

      -- Comandos y mapeos de control
      vim.api.nvim_create_user_command("DBUse", function(opts)
        local url = _with_db(opts.args)
        if url then
          vim.b.db = url
          vim.b.db_lock = true -- bloquea al usar DBUse
          vim.notify("b:db = " .. url .. "  (locked)")
        end
      end, { nargs = 1 })

      vim.api.nvim_create_user_command("DBLock", function()
        vim.b.db_lock = true
        vim.notify "DB context LOCKED for this buffer"
      end, {})

      vim.api.nvim_create_user_command("DBUnlock", function()
        vim.b.db_lock = false
        vim.notify "DB context UNLOCKED for this buffer"
      end, {})

      vim.api.nvim_create_user_command("DBClear", function()
        vim.b.db = _base_url() or ""
        vim.b.db_lock = false
        vim.notify("b:db cleared → " .. tostring(vim.b.db))
      end, {})

      vim.api.nvim_create_user_command("DBHere", function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local db = _find_last_use(row)
        if db then
          local url = _with_db(db)
          if url then
            vim.b.db = url
            vim.b.db_lock = true
            vim.notify("b:db = " .. url .. "  (locked from nearest USE)")
          end
        else
          vim.notify("No se encontró 'USE <db>;' arriba del cursor.", vim.log.levels.WARN)
        end
      end, {})

      vim.keymap.set("n", "<leader>ud", function()
        local db = vim.fn.input "DB name: "
        if db ~= "" then vim.cmd("DBUse " .. db) end
      end, { desc = "DB: Fijar BD del buffer (bloquea)" })

      vim.keymap.set("n", "<leader>uL", function()
        vim.b.db_lock = not vim.b.db_lock
        vim.notify("DB lock: " .. tostring(vim.b.db_lock))
      end, { desc = "DB: Toggle lock buffer" })

      vim.api.nvim_create_user_command(
        "DBBuf",
        function()
          vim.notify(
            "b:db=" .. tostring(vim.b.db) .. " | locked=" .. tostring(vim.b.db_lock) .. " | g:db=" .. tostring(vim.g.db)
          )
        end,
        {}
      )

      -- Ejecución INTELIGENTE (respeta bloqueo)
      local function smart_run_line()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        _ensure_db_for_row(row)
        vim.cmd ":.DB"
      end

      local function smart_run_selection()
        local srow = vim.fn.line "'<"
        local erow = vim.fn.line "'>"
        _ensure_db_for_row(erow)
        vim.cmd ":'<','>DB"
      end

      local function smart_run_file()
        local last = vim.fn.line "$"
        _ensure_db_for_row(last)
        vim.cmd ":%DB"
      end

      vim.keymap.set("n", "<leader>ql", smart_run_line, { desc = "DB: Ejecutar línea (smart, respeta lock)" })
      vim.keymap.set("v", "<leader>qe", smart_run_selection, { desc = "DB: Ejecutar selección (smart, respeta lock)" })
      vim.keymap.set("n", "<leader>qa", smart_run_file, { desc = "DB: Ejecutar archivo (smart, respeta lock)" })

      -- Celdas '-- %%' (smart + respeta lock)
      local function run_sql_cell_smart()
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
        _ensure_db_for_row(erow)
        if srow <= erow then vim.cmd(("%d,%dDB"):format(srow, erow)) end
      end
      vim.keymap.set("n", "<leader>qc", run_sql_cell_smart, { desc = "DB: Ejecutar celda (-- %% , smart)" })

      -- Formato & commentstring
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function(args)
          vim.bo[args.buf].formatexpr = ""
          vim.bo[args.buf].indentexpr = ""
          vim.b[args.buf].autoformat = true
        end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql" },
        callback = function(args) vim.bo[args.buf].commentstring = "-- %s" end,
      })

      -- Autodetección cabecera '-- DB: <name>' (no pisa si está bloqueado)
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
        pattern = { "*.sql", "*.mysql" },
        callback = function(args)
          if (vim.b[args.buf].db or "") ~= "" or vim.b[args.buf].db_lock then return end
          local n = math.min(10, vim.api.nvim_buf_line_count(args.buf))
          local lines = vim.api.nvim_buf_get_lines(args.buf, 0, n, false)
          for _, ln in ipairs(lines) do
            local db = ln:match "^%s*%-%-%s*DB:%s*([%w_]+)%s*$"
            if db and db ~= "" then
              local url = _with_db(db)
              if url then
                vim.b[args.buf].db = url
                vim.notify("Detectado '-- DB: " .. db .. "' → b:db=" .. url)
              end
              break
            end
          end
        end,
      })
      -----------------------------------------------------------------------
    end,
  },

  -- Conform: sql-formatter → sqlfluff
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { sql = { "sql_formatter", "sqlfluff" } },
      formatters = {
        sql_formatter = {
          command = "sql-formatter",
          condition = function() return vim.fn.executable "sql-formatter" == 1 end,
          args = function()
            local cfg = vim.fn.expand "~/.sql-formatter.json"
            if vim.fn.filereadable(cfg) == 1 then return { "--config", cfg } end
            return { "--language", "mysql" }
          end,
          stdin = true,
          exit_codes = { 0 },
        },
        sqlfluff = {
          command = "sqlfluff",
          args = { "fix", "-", "--dialect", "mysql", "--config", vim.fn.expand "~/.sqlfluff" },
          stdin = true,
          exit_codes = { 0, 1 },
          env = { SQLFLUFF_CONFIG = vim.fn.expand "~/.sqlfluff" },
        },
      },
      run_all_formatters = true,
      stop_after_first = false,
      notify_on_error = false,
    },
    config = function(_, opts)
      require("conform").setup(opts)
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
