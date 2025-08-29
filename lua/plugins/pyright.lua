-- pyright.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {
        -- Detecta la raíz del proyecto de forma robusta
        root_dir = function(fname)
          local util = require "lspconfig.util"
          return util.root_pattern("pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git")(fname)
            or util.find_git_ancestor(fname)
            or util.path.dirname(fname)
        end,

        -- Ajustes de análisis pensados para Data Science
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic", -- puedes subir a "strict" cuando quieras
              autoImportCompletions = true,
              diagnosticMode = "workspace", -- analiza todo el workspace
              useLibraryCodeForTypes = true,
            },
          },
        },

        -- Ajusta el venv dinámicamente si hay VIRTUAL_ENV (venv-selector, direnv, etc.)
        on_new_config = function(config, _)
          local venv = vim.env.VIRTUAL_ENV
          if venv and #venv > 0 then
            -- Para Pyright, lo más limpio es indicar venvPath + venv (en vez de pythonPath)
            local util = require "lspconfig.util"
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.venvPath = util.path.dirname(venv)
            config.settings.python.venv = vim.fn.fnamemodify(venv, ":t")
          end
        end,
      },
    },
  },
}
