return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/neotest-python",
  },
  ft = { "python" },
  config = function()
    require("neotest").setup {
      adapters = {
        require "neotest-python" {
          dap = { justMyCode = false },
          runner = "pytest",
        },
      },
      log_level = 3,
      consumers = {},
    }
  end,
}
