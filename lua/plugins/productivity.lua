-- plugins/productivity.lua
return {
  -- TODO/FIXME en comentarios
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    config = function(_, opts)
      require("todo-comments").setup(opts)
      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })
    end,
  },

  -- Resalta repeticiones de variables
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function() require("illuminate").configure { delay = 200 } end,
  },

  -- Navegación avanzada (Harpoon 1)
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
      { "<leader>hh", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon quick menu" },
      { "<leader>1", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
      { "<leader>2", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
      { "<leader>3", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
    },
    config = true,
  },

  -- === Autoformato SÓLO para Python (black + isort) ==========================
  {
    "stevearc/conform.nvim",
    ft = { "python" },
    opts = {
      formatters_by_ft = {
        -- mantenemos Lua/JS en none-ls, aquí solo Python para no duplicar
        python = { "black", "isort" },
      },
      format_on_save = {
        lsp_fallback = true, -- p.ej. si black/isort no están disponibles
        timeout_ms = 800,
      },
    },
    keys = {
      {
        "<leader>pf",
        function() require("conform").format { async = true, lsp_fallback = true } end,
        desc = "Python: format (black+isort)",
      },
    },
  },
}
