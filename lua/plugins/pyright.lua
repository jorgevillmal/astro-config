-- lua/plugins/pyright.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {
        single_file_support = true,

        -- Raíz del proyecto robusta
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
              -- "off" (laxo), "basic" (recomendado), "strict" (exigente)
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace", -- cambia a "openFilesOnly" si va pesado
              useLibraryCodeForTypes = true,
              -- evita ruido en análisis
              exclude = {
                "**/.git",
                "**/.hg",
                "**/.svn",
                "**/__pycache__",
                "**/.mypy_cache",
                "**/.venv",
                "**/venv",
                "**/env",
                "**/build",
                "**/dist",
              },
              -- extraPaths = { "src" }, -- descomenta si usas layout src/
              -- stubPath = "typings",   -- si usas stubs locales
            },
          },
        },

        -- Selecciona el entorno: VIRTUAL_ENV > .venv/venv en raíz > CONDA_PREFIX
        on_new_config = function(config, root_dir)
          local util = require "lspconfig.util"

          local venv = vim.env.VIRTUAL_ENV
          if not venv or #venv == 0 then
            -- busca carpetas virtualenv comunes en el repo
            for _, name in ipairs { ".venv", "venv", "env" } do
              local p = util.path.join(root_dir, name)
              if vim.fn.isdirectory(p) == 1 then
                venv = p
                break
              end
            end
          end
          if (not venv or #venv == 0) and vim.env.CONDA_PREFIX then venv = vim.env.CONDA_PREFIX end

          if venv and #venv > 0 then
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            -- Para Pyright, venvPath + venv es lo más estable
            config.settings.python.venvPath = util.path.dirname(venv)
            config.settings.python.venv = vim.fn.fnamemodify(venv, ":t")
          end
        end,
      },
    },
  },
}
