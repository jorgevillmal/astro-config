---@type LazySpec
return {
  -- Configurar Mason para la instalación de servidores LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls", -- LSP para Lua
        "texlab", -- LSP para LaTeX
        "sqls", -- LSP para SQL
        "pyright", -- LSP para Python ✅
      },
    },
  },

  -- Configurar Mason-Null-LS para la instalación de formateadores y linters
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "stylua", -- Formateador para Lua
        "latexindent", -- Formateador para LaTeX
        "sqlfluff", -- Formateador/Linter para SQL
        "black", -- Formateador para Python ✅
        "isort", -- Ordenador de imports Python ✅
        "flake8", -- Linter para Python ✅
      },
    },
  },

  -- Configurar Mason-DAP para debuggers
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python", -- Debugger para Python (debugpy) ✅
      },
    },
  },
}
