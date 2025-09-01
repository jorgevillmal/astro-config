return {
  "3rd/image.nvim",
  version = false, -- usa HEAD
  lazy = true,
  event = "VeryLazy",
  opts = {
    -- Forzar backend: Kitty (más estable con Molten)
    backend = "kitty",

    integrations = {
      markdown = { enabled = true },
      neorg = { enabled = false },
      typst = { enabled = false },
      html = { enabled = false },
    },

    -- Tamaños recomendados para plots de matplotlib/seaborn
    max_width = 200, -- px
    max_height = 80, -- px
    max_width_window_percentage = 0.8,
    max_height_window_percentage = 0.6,

    -- Renderizar incluso cuando el buffer no tiene foco
    editor_only_render_when_focused = false,

    -- Opcional: ajusta calidad de escalado
    kitty_method = "normal", -- "normal" | "transfer"
  },
}
