return {
  -- 1) REPL: IPython con celdas estilo Jupytext/VSCode (%%)
  {
    "bfredl/nvim-ipy",
    ft = { "python" },
    config = function()
      -- Marcador de celda
      vim.g.ipy_celldef = "%%"

      -- Preferir ipython/python del venv si existe
      local venv = os.getenv "VIRTUAL_ENV"
      if venv and #venv > 0 then
        local bin = venv .. "/bin/"
        -- usa ipython si existe, si no python
        local ipy = vim.fn.executable(bin .. "ipython") == 1 and (bin .. "ipython")
          or (vim.fn.executable(bin .. "python") == 1 and (bin .. "python") or nil)

        if ipy then
          vim.g.ipy_term = ipy -- para terminal backend
          vim.g.ipy_python = ipy -- para :IPyRun, etc.
        else
          vim.g.ipy_term = "ipython"
        end
      else
        vim.g.ipy_term = "ipython"
      end

      -- Keymaps útiles, buffer-local, sólo en Python
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc, silent = true })
        vim.keymap.set("v", lhs, rhs, { buffer = true, desc = desc, silent = true })
      end

      -- Crea los maps cuando se edite un buffer python
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          -- Enviar selección o línea actual
          map("<leader>rl", "<Plug>(IPy-Run)", "IPy: enviar línea/selección")
          -- Ejecutar celda actual (delimitada por %%)
          map("<leader>rc", "<Plug>(IPy-RunCell)", "IPy: ejecutar celda %%")
          -- Ejecutar todo el buffer
          map("<leader>ra", "<cmd>IPyRunFile<cr>", "IPy: ejecutar archivo")
          -- Abrir/Conectar REPL (si no está)
          map("<leader>rr", "<cmd>IPyConnect<cr>", "IPy: conectar REPL")
          -- Interrumpir (Ctrl-C) kernel
          map("<leader>ri", "<cmd>IPyInterrupt<cr>", "IPy: interrumpir")
          -- Reiniciar kernel (si backend lo soporta)
          map("<leader>rR", "<cmd>IPyRestart<cr>", "IPy: reiniciar kernel")
          -- Limpiar terminal del REPL
          map("<leader>rk", "<cmd>IPyClear<cr>", "IPy: limpiar REPL")
        end,
      })
    end,
  },

  -- 2) DAP para Python (debugpy)
  {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local py = nil
      -- Si hay venv activo, usa su python para debugpy
      local venv = os.getenv "VIRTUAL_ENV"
      if venv and #venv > 0 and vim.fn.executable(venv .. "/bin/python") == 1 then
        py = venv .. "/bin/python"
      else
        -- fallback: usa el python del paquete debugpy instalado por Mason
        local ok, mr = pcall(require, "mason-registry")
        if ok then
          local pkg = mr.get_package "debugpy"
          if pkg:is_installed() then
            local root = pkg:get_install_path()
            local cand = root .. "/venv/bin/python"
            if vim.fn.executable(cand) == 1 then py = cand end
          end
        end
      end

      -- Si todo falla, intenta con 'python' del PATH
      if not py then py = "python" end

      require("dap-python").setup(py)
    end,
  },
}
