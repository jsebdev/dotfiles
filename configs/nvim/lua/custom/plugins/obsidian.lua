return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/My Drive/second_brain/second_brain_vault",
        overrides = {
          notes_subdir = "fleeting_notes",
        },
      },
    },

    -- Where to put new notes. Valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = "notes_subdir",

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "ARCHIVE/journal",
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = "daily note template",
    },

    templates = {
      folder = "ARCHIVE/templates",
    },

    attachments = {
      -- The default folder to place images in via `:ObsidianPasteImg`.
      -- If this is a relative path it will be interpreted as relative to the vault root.
      img_folder = "ARCHIVE/attachments",
    },

    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    mappings = {
      ["gt"] = {
        action = function() vim.cmd("ObsidianToday") end,
        opts = { noremap = true, desc = "Open today's daily note" },
      },
    },

    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
      name = "telescope.nvim",
      -- Optional, configure key mappings for the picker. These are the defaults.
      note_mappings = {
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },
    },

    -- Optional, customize the frontmatter that obsidian.nvim injects into new notes.
    -- Returning nil disables auto-generated frontmatter (id, aliases, tags).
    ---@return table
    note_frontmatter_func = function(note)
      -- Add the title of the note as an alias.
      -- if note.title then
      --   note:add_alias(note.title)
      -- end

      -- local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      local out = { id = note.id }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end,

    -- Optional, customize how note IDs are generated given an optional title.
    -- Use title as-is to match Obsidian app behavior (e.g. [[word1 word2]] → "word1 word2.md").
    -- Falls back to timestamp only when no title is provided.
    note_id_func = function(title)
      if title ~= nil then
        return title
      else
        return tostring(os.time())
      end
    end,
  },
}
