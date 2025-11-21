-- lazy.nvim bootstrap
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({
  "nvim-lualine/lualine.nvim",
  "nvim-treesitter/nvim-treesitter",
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "folke/tokyonight.nvim",
},

{
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      sh = {"shellcheck"},
      bash = {"shellcheck"},
      zsh = {"shellcheck"},
      python = {"pylint"},       -- optional
    }

    -- Run lint automatically on write
    vim.api.nvim_create_autocmd("BufWritePost", {
      callback = function()
        lint.try_lint()
      end,
    })
  end
})


-- LEADER KEY -------------------------------------------------------------
vim.g.mapleader = " "

-- UI ---------------------------------------------------------------------
vim.opt.number = true                  -- absolute line numbers
vim.opt.relativenumber = true          -- relative line numbers
vim.opt.laststatus = 3                 -- global status line (better than laststatus=2)

-- SEARCH -----------------------------------------------------------------
vim.opt.ignorecase = true              -- case-insensitive search
vim.opt.smartcase = true               -- unless uppercase present
vim.opt.incsearch = true               -- search while typing
vim.opt.hlsearch = true                -- highlight search results

-- TABS & INDENTATION -----------------------------------------------------
vim.opt.expandtab = true               -- convert tabs to spaces
vim.opt.tabstop = 4                    -- 1 tab = 4 spaces
vim.opt.shiftwidth = 4                 -- indentation amount
vim.opt.backspace = { "indent", "eol", "start" } -- sane backspace behavior

-- CLIPBOARD --------------------------------------------------------------
vim.opt.clipboard = "unnamedplus"      -- use system clipboard

-- MOUSE ------------------------------------------------------------------
vim.opt.mouse = "a"                    -- enable mouse

-- ARROW-KEY DISABLING (OPTIONAL) -----------------------------------------
vim.keymap.set("n", "<Left>",  ":echo 'Use h'<CR>")
vim.keymap.set("n", "<Right>", ":echo 'Use l'<CR>")
vim.keymap.set("n", "<Up>",    ":echo 'Use k'<CR>")
vim.keymap.set("n", "<Down>",  ":echo 'Use j'<CR>")

vim.keymap.set("i", "<Left>",  "<ESC>:echo 'Use h'<CR>")
vim.keymap.set("i", "<Right>", "<ESC>:echo 'Use l'<CR>")
vim.keymap.set("i", "<Up>",    "<ESC>:echo 'Use k'<CR>")
vim.keymap.set("i", "<Down>",  "<ESC>:echo 'Use j'<CR>")

-- PASTE MODE TOGGLE ------------------------------------------------------
vim.keymap.set("n", "<leader>p", function()
  vim.opt.paste = not vim.opt.paste:get()
  print("paste = " .. (vim.opt.paste:get() and "ON" or "OFF"))
end)

