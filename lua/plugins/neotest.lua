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
          -- ajusta la ruta si usas entorno virtual
          dap = { justMyCode = false },
          runner = "pytest",
        },
      },
    }

    local wk = require "which-key"
    wk.register({
      t = {
        name = "Tests",
        f = { function() require("neotest").run.run(vim.fn.expand "%") end, "Run File" },
        n = { function() require("neotest").run.run() end, "Run Nearest Test" },
        l = { function() require("neotest").run.run_last() end, "Run Last Test" },
        o = { function() require("neotest").output.open { enter = true } end, "Open Output" },
        s = { function() require("neotest").summary.toggle() end, "Toggle Summary" },
      },
    }, { prefix = "<leader>" })
  end,
}
