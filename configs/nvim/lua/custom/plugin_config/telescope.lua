local M = {}
local telescopeConfig = require 'telescope.config'

local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
-- serach in hidden/dot files
table.insert(vimgrep_arguments, '--hidden')

function M.setup()
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- After running this command, a window will open up and you're able to
  -- type in the prompt window. You'll see a list of `help_tags` options and
  -- a corresponding preview of the help.
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  -- [[ Configure Telescope ]]
  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    -- You can put your default mappings / updates / etc. in here
    --  All the info you're looking for is in `:help telescope.setup()`
    --
    -- defaults = {
    --   mappings = {
    --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
    --   },
    -- },
    defaults = {
      vimgrep_arguments = vimgrep_arguments,
      path_display = { 'filename_first' },
      layout_strategy = 'vertical',
      layout_config = {
        height = 0.99,
        width = 0.99,
        preview_cutoff = 1,
      },
    },
    pickers = {
      find_files = {
        no_ignore = true,
        hidden = true,
        find_command = {
          'rg', '--files', '--hidden',
          '--glob', '!**/.git/*',
          '--glob', '!**/node_modules/*',
          '--glob', '!**/.angular/*',
          '--glob', '!**/__pycache__/*',
          '--glob', '!**/.terraform/*',
        },
      },
      live_grep = {
        glob_pattern = { '!**/node_modules/*' },
        path_display = { 'filename_first' },
      },
      lsp_references = {
        show_line = false,
      },
      lsp_definitions = {
        show_line = false,
      },
      lsp_implementations = {
        show_line = false,
      },
      lsp_type_definitions = {
        show_line = false,
      },
    },
    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown(),
      },
    },
  }

  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>scw', builtin.grep_string, { desc = '[S]earch [C]urrent [W]ord' })
  vim.keymap.set('n', '<leader>sgg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>sw', require('custom.utils.jump_to_window').jump_to_window_telescope, { desc = '[S]earch [W]indows' })

  -- Slightly advanced example of overriding default behavior and theme
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config', hidden = true }
  end, { desc = '[S]earch [N]eovim files' })

  vim.keymap.set('n', '<leader>sa', function()
    builtin.live_grep {
      prompt_title = 'Live grep in all files even ignored by gitignore',
      additional_args = { '--no-ignore'},
    }
  end, { desc = '[S]earch in [A]ll Files' })

  -- custom live grep
  vim.keymap.set('n', '<leader>sgp', function()
    builtin.live_grep {
      prompt_title = 'Live grep in Python files',
      additional_args = function(opts)
        return { "--glob=*.py" }
      end
    }
  end, { desc = '[S]earch Python files' })

  vim.keymap.set('n', '<leader>sgt', function()
    builtin.live_grep {
      prompt_title = 'Live grep in TypeScript files',
      additional_args = function(opts)
        return { "--glob=*.ts", "--glob=*.tsx" }
      end
    }
  end, { desc = '[S]earch TypeScript files' })
end

return M
