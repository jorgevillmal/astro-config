-- ~/.config/nvim/lua/plugins/jupyter.lua
return {
  {
    -- No reconfiguramos molten (ya lo haces en molten.lua), aquí sólo añadimos helpers
    "benlubas/molten-nvim",
    init = function()
      local function detect_env()
        local venv = vim.env.VIRTUAL_ENV
        local cpre = vim.env.CONDA_PREFIX
        if cpre and #cpre > 0 then
          local name = vim.env.CONDA_DEFAULT_ENV or vim.fn.fnamemodify(cpre, ":t")
          return { kind = "conda", path = cpre, name = name, py = cpre .. "/bin/python" }
        elseif venv and #venv > 0 then
          local name = vim.fn.fnamemodify(venv, ":t")
          return { kind = "venv", path = venv, name = name, py = venv .. "/bin/python" }
        else
          -- sin entorno: usa python del PATH
          return { kind = "system", path = "", name = "system", py = "python" }
        end
      end

      local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = "Jupyter" }) end

      -- 1) Instala ipykernel + jupyter_client en el entorno ACTUAL
      vim.api.nvim_create_user_command("JupyterEnsure", function()
        local env = detect_env()
        notify(("Instalando ipykernel en %s (%s) …"):format(env.name, env.kind))
        local out = vim.fn.system { env.py, "-m", "pip", "install", "-q", "ipykernel", "jupyter_client" }
        if vim.v.shell_error == 0 then
          notify "Listo: ipykernel + jupyter_client instalados"
        else
          notify("Error instalando paquetes:\n" .. out, vim.log.levels.ERROR)
        end
      end, {})

      -- 2) Crea el kernelspec (aparece en `jupyter kernelspec list`)
      vim.api.nvim_create_user_command("JupyterCreateKernel", function(opts)
        local env = detect_env()
        local name = opts.args ~= "" and opts.args or env.name
        local display = ("Python (%s:%s)"):format(env.kind, name)
        notify(("Creando kernelspec '%s'…"):format(display))
        local cmd = {
          env.py,
          "-m",
          "ipykernel",
          "install",
          "--user",
          "--name",
          name,
          "--display-name",
          display,
        }
        local out = vim.fn.system(cmd)
        if vim.v.shell_error == 0 then
          notify(("Kernel creado: %s"):format(display))
        else
          notify("Error creando kernel:\n" .. out, vim.log.levels.ERROR)
        end
      end, { nargs = "?", complete = "file" })

      -- 3) Selector de kernel -> hace :MoltenInit -f -k <kernel_name>
      vim.api.nvim_create_user_command("JupyterPickKernel", function()
        local json = vim.fn.system { "jupyter", "kernelspec", "list", "--json" }
        if vim.v.shell_error ~= 0 or not json or #json == 0 then
          notify("No pude obtener la lista de kernels. ¿Está instalado `jupyter`?", vim.log.levels.WARN)
          return
        end
        local ok, parsed = pcall(vim.json.decode, json)
        if not ok then
          ok, parsed = pcall(vim.fn.json_decode, json)
        end
        if not ok then
          notify("No pude parsear la salida de kernelspec", vim.log.levels.ERROR)
          return
        end
        local items = {}
        for name, spec in pairs(parsed.kernelspecs or {}) do
          table.insert(items, { name = name, label = (spec.spec and spec.spec.display_name) or name })
        end
        if #items == 0 then
          notify("No hay kernels registrados. Usa :JupyterCreateKernel primero.", vim.log.levels.WARN)
          return
        end
        vim.ui.select(items, {
          prompt = "Elige kernel para Molten:",
          format_item = function(it) return ("%s  [%s]"):format(it.label, it.name) end,
        }, function(choice)
          if not choice then return end
          vim.cmd(("MoltenInit -f -k %s"):format(choice.name))
          notify(("Kernel activo: %s"):format(choice.label))
        end)
      end, {})

      -- (Opcional) helpers rápidos
      vim.api.nvim_create_user_command("JupyterRestart", function()
        vim.cmd "MoltenStop"
        vim.cmd "JupyterPickKernel"
      end, {})

      -- Keymaps útiles (puedes cambiarlos si ya usas otros):
      vim.keymap.set("n", "<leader>mE", "<cmd>JupyterEnsure<cr>", { desc = "Jupyter: asegurar ipykernel" })
      vim.keymap.set("n", "<leader>mK", "<cmd>JupyterCreateKernel<cr>", { desc = "Jupyter: crear kernel del entorno" })
      vim.keymap.set("n", "<leader>mk", "<cmd>JupyterPickKernel<cr>", { desc = "Jupyter: elegir kernel" })
      vim.keymap.set("n", "<leader>mr", "<cmd>JupyterRestart<cr>", { desc = "Jupyter: reiniciar kernel" })
      -- tus atajos de molten (evaluar celda, init, stop) ya están en molten.lua
    end,
  },
}
