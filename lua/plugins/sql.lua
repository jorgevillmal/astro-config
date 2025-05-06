return {
  { -- LSP para SQL (sqls)
    "nanotee/sqls.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    ft = { "sql" },
    config = function()
      require("lspconfig").sqls.setup {
        on_attach = function(client, bufnr)
          require("sqls").on_attach(client, bufnr)
          vim.cmd [[ let b:db = 'mysql://root@localhost' ]]
          -- 🔒 Desactiva el formateo del LSP sqls para evitar interferencias
          client.server_capabilities.documentFormattingProvider = false
        end,
        settings = {
          sqls = {
            connections = {
              {
                driver = "mysql",
                dataSourceName = "root@tcp(127.0.0.1:3306)/",
              },
            },
          },
        },
      }
    end,
  },

  { -- Motor principal de dadbod
    "tpope/vim-dadbod",
    lazy = false,
  },

  { -- Interfaz visual de dadbod
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = "~/.config/db_ui"
    end,
  },

  { -- Autocompletado para dadbod
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql" },
  },

  { -- Formato con sqlfluff
    "stevearc/conform.nvim",
    opts = {
      -- 🧠 Formatear al guardar SOLO en archivos SQL
      format_on_save = function(bufnr) return vim.bo[bufnr].filetype == "sql" end,
      formatters_by_ft = {
        sql = { "sqlfluff" },
      },
      formatters = {
        sqlfluff = {
          prepend_args = {
            "fix",
            "--dialect",
            "mysql",
          },
          command = (function()
            local host = vim.uv.os_gethostname()
            if host == "Jorges-MacBook-Pro.local" then
              return "/Users/jorgevillmal/.venvs/astroenv/bin/sqlfluff"
            elseif host == "Jorges-Mac-mini.local" then
              return "/Users/jorgevillarreal/.venvs/astronvim/bin/sqlfluff"
            end
          end)(),
        },
      },
    },
  },
}
