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
      formatters_by_ft = {
        sql = { "sqlfluff" },
      },
      formatters = {
        sqlfluff = {
          prepend_args = {
            "fix",
            "--dialect",
            "mysql",
            "--exclude-rules",
            "L009",
          },
          command = "/Users/jorgevillmal/.venvs/astroenv/bin/sqlfluff",
        },
      },
    },
  },
}
