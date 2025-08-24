return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      -- Teclas estilo VSCode
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
        ["Select All"] = "<C-a>",
        ["Skip Region"] = "<C-x>",
        ["Remove Region"] = "<C-p>", -- anterior / eliminar
        ["Add Cursor At Pos"] = "g<C-n>",
      }
      -- UI mínima
      vim.g.VM_theme = "iceblue"
      vim.g.VM_show_warnings = 0
    end,
  },
  -- Si tenías otro plugin de multicursor, desactívalo aquí:
  { "smoka7/multicursors.nvim", enabled = false },
}
