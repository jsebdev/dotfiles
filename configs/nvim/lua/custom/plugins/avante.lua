return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-opus-5",
        timeout = 30000,
        context_window = 1000000,
        extra_request_body = {
          temperature = 1, -- current models reject any non-default temperature
          max_tokens = 64000,
        },
      },
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        extra_request_body = {
          temperature = 0,
          max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
        },
      },
    },
    -- Drives the Claude Code CLI over ACP, which bills your subscription rather
    -- than ANTHROPIC_API_KEY. Inactive until `provider` above is set to
    -- "claude-code" (or :AvanteSwitchProvider claude-code). Needs a current
    -- avante plus `claude-agent-acp` on PATH -- see the notes below.
    acp_providers = {
      ["claude-code"] = {
        command = "claude-agent-acp",
        args = {},
        env = {
          NODE_NO_WARNINGS = "1",
          -- Deliberately blank, not inherited: avante's default forwards
          -- ANTHROPIC_API_KEY here, and a populated key makes Claude Code bill
          -- the API instead of falling back to the subscription login.
          ANTHROPIC_API_KEY = "",
          ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
        },
      },
    },
    mappings = {
      sidebar = {
        switch_windows = "<C-n>",
      }
    }
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  keys = {
    { "<leader>ae", "<cmd>AvanteClear<cr>", desc = "[A]vante [E]rase history" },
  },
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick",       -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp",            -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua",            -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
