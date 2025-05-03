return {
  -- IPython sender
  {
    "bfredl/nvim-ipy",
    ft = { "python" },
    config = function()
      vim.g.ipy_celldef = "##"
      vim.g.ipy_term = "ipython"
    end,
  },

  -- Autoformato con black + isort
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black", "isort" },
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
    },
  },

  -- Depuración con DAP
  {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function() require("dap-python").setup "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python" end,
  },
}
