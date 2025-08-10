---@type LazySpec
return {
  -- Configurar Mason para la instalación de servidores LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "texlab", -- LSP para LaTeX
        "sqls", -- LSP para SQL
      },
    },
  },
  -- Configurar Mason-Null-LS para la instalación de formateadores y linters
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "latexindent", -- Formateador para LaTeX
        "sqlfluff", -- Formateador/linter para SQL
      },
    },
  },
  -- Configurar Mason-DAP para debuggers
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },
}
