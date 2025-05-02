-- pyright.lua
return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require "lspconfig"

    lspconfig.pyright.setup {
      root_dir = function(fname)
        local root_files = {
          ".git",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
        }
        local root = lspconfig.util.root_pattern(unpack(root_files))(fname) or lspconfig.util.path.dirname(fname)

        if root == nil then
          return vim.fn.getcwd()
        else
          return root
        end
      end,
      settings = {
        python = {
          -- Directorio donde se encuentran los entornos virtuales
          venvPath = "/Users/jorgevillmal/.venvs",
          -- Ruta del intérprete de Python del entorno virtual
          pythonPath = "/Users/jorgevillmal/.venvs/astroenv/bin/python",
          analysis = {
            logLevel = "Trace", -- Habilita el registro detallado
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
            typeCheckingMode = "off", -- Desactiva la comprobación de tipos estricta para evitar errores innecesarios
          },
        },
      },
    }
  end,
}
