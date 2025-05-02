return {
  {
    "lervag/vimtex",
    config = function()
      -- 🖨️ Compilador automático (latexmk)
      vim.g.vimtex_compiler_method = "latexmk"

      -- 📄 Configuración del visor de PDF en macOS (Skim)
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1 -- Activar sincronización automática
      vim.g.vimtex_view_skim_activate = 1 -- Llevar Skim al frente tras compilar

      -- 🛠️ Configuración de latexmk para una mejor compilación
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf", -- Generar archivo PDF
          "-interaction=nonstopmode", -- Continuar sin detenerse en errores
          "-synctex=1", -- Habilitar SyncTeX para sincronización con Skim
          "-shell-escape", -- Permitir ejecución de scripts externos (si usas TikZ o Minted)
          "-silent", -- Reducir el ruido en la consola
        },
      }

      -- 🎯 Motores alternativos de compilación
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-pdf",
        pdflatex = "-pdf",
        xelatex = "-xelatex",
        lualatex = "-lualatex",
      }

      -- ✍️ Configurar corrector ortográfico automático en español para LaTeX
      vim.cmd [[
        augroup VimTeXSpellCheck
          autocmd!
          autocmd FileType tex setlocal spell spelllang=es
        augroup END
      ]]

      -- 📌 Configurar plegado automático para documentos largos
      vim.g.vimtex_fold_enabled = 1

      -- 🚀 Deshabilitar la ventana de errores (Quickfix) para evitar distracciones
      vim.g.vimtex_quickfix_mode = 0

      -- 🏆 Habilitar autocompletado con vimtex (si no usas LSP para esto)
      vim.g.vimtex_complete_enabled = 1

      -- 🔍 Asegurar integración con `texlab` si lo tienes instalado
      if require("lspconfig")["texlab"] then require("lspconfig").texlab.setup {} end
    end,
  },
}
