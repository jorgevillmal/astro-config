-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Eliminar la primera línea que bloquea el archivo
-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason plugins

---@type LazySpec
return {
  -- Configurar Mason para la instalación de servidores LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "texlab", -- LSP para LaTeX
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
