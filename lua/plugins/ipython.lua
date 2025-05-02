return {

  {
    "bfredl/nvim-ipy",
    ft = { "python" }, -- Solo cargar para archivos Python
    config = function()
      vim.g.ipy_celldef = "##" -- Define los marcadores de celda, puede cambiarse según tus preferencias.
      vim.g.ipy_term = "ipython" -- Comando para iniciar IPython.
    end,
  },
}
