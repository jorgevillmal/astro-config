return {
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
        onSave = true, -- Compilar automáticamente al guardar
      },
      forwardSearch = {
        executable = "skim",
        args = { "--reuse-window", "%p" },
      },
      chktex = { onOpenAndSave = true },
      diagnosticsDelay = 300, -- Reducir el tiempo de espera de diagnósticos
    },
  },
}
