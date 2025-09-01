return {
  "benlubas/molten-nvim",
  -- Molten es un remote-plugin: compilar/registrar al instalar
  build = ":UpdateRemotePlugins",
  dependencies = {
    -- imágenes inline (opcional pero recomendado con Kitty)
    "3rd/image.nvim",
  },
  ft = { "python", "markdown", "quarto" },
  config = function()
    -- ========= Integración con image.nvim (solo si existe y estamos en kitty) =========
    local have_image = pcall(require, "image")
    if have_image and (vim.env.KITTY_PID or "") ~= "" then
      vim.g.molten_image_provider = "image.nvim"
    else
      -- si no hay kitty o image.nvim, que Molten use su método por defecto
      vim.g.molten_image_provider = nil
    end

    -- ========= UX / Ventanas de salida =========
    -- abre automáticamente la ventana de output cuando hay resultados
    vim.g.molten_auto_open_output = true
    -- limita la altura de la ventana de resultados
    vim.g.molten_output_win_max_height = 20
    -- desactiva resultados como virtual text (más limpio con plots/imágenes)
    vim.g.molten_virt_text_output = false

    -- ========= Keymaps: iniciar, ejecutar y parar =========
    local map = vim.keymap.set
    local desc = function(d) return { desc = d, silent = true } end
    map("n", "<leader>mi", ":MoltenInit<CR>", desc "Molten: iniciar kernel")
    map("n", "<leader>mc", ":MoltenEvaluateCell<CR>", desc "Molten: ejecutar celda ##")
    map("n", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>", desc "Molten: ejecutar selección")
    map("n", "<leader>ms", ":MoltenStop<CR>", desc "Molten: parar kernel")

    -- ========= Resaltado de celdas estilo VSCode/Jupytext =========
    -- marca líneas que empiezan por '##' como separadores de celda
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "markdown", "quarto" },
      callback = function()
        vim.cmd [[syntax match MoltenCellMarker /^\s*##\%(\s.*\)\?$/]]
        vim.cmd [[highlight link MoltenCellMarker Comment]]
      end,
    })

    -- (opcional) si quieres que el marcador de celda sea exactamente '##'
    -- en lugar de detectar por sintaxis, puedes decirle a Molten:
    -- vim.g.molten_cell_markers = { "##" }
  end,
}
