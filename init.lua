-- lazy.nvim bootstrap
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({
  -- UI & Appearance
  "nvim-lualine/lualine.nvim",
  "folke/tokyonight.nvim",
  
  -- Treesitter (better syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  
  -- Telescope (fuzzy finder)
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
  
  -- LSP Setup
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },
  "williamboman/mason-lspconfig.nvim",
  
  -- Autocompletion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  
  -- Linting
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        sh = {"shellcheck"},
        bash = {"shellcheck"},
        zsh = {"shellcheck"},
        python = {"pylint"},
      }

      -- Run lint automatically on write
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          lint.try_lint()
        end,
      })
    end
  },
})

-- ============================================================================
-- LSP SETUP WITH MASON
-- ============================================================================
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")
local cmp = require("cmp")

-- Mason configuration
mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- LSP servers to automatically install
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",           -- Lua
    "pylsp",            -- Python (python-lsp-server)
    -- Add more servers as needed:
    -- "ts_ls",          -- TypeScript/JavaScript
    -- "bashls",         -- Bash
    -- "marksman",       -- Markdown
    -- "jsonls",         -- JSON
  },
  automatic_installation = true,
})

-- Autocompletion setup
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

-- LSP server configuration
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  
  -- Keymaps
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format { async = true }
  end, bufopts)
end

-- Apply on_attach and capabilities to each server
local capabilities = require('cmp_nvim_lsp').default_capabilities()

mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,
})

-- ============================================================================
-- UI SETTINGS
-- ============================================================================

-- Make sure parsers are found or compiled
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/parsers")

-- LEADER KEY
vim.g.mapleader = " "

-- UI
vim.opt.number = true                  -- absolute line numbers
vim.opt.relativenumber = true          -- relative line numbers
vim.opt.laststatus = 3                 -- global status line
vim.opt.cursorline = true              -- highlight current line

-- SEARCH
vim.opt.ignorecase = true              -- case-insensitive search
vim.opt.smartcase = true               -- unless uppercase present
vim.opt.incsearch = true               -- search while typing
vim.opt.hlsearch = true                -- highlight search results

-- TABS & INDENTATION
vim.opt.expandtab = true               -- convert tabs to spaces
vim.opt.tabstop = 4                    -- 1 tab = 4 spaces
vim.opt.shiftwidth = 4                 -- indentation amount
vim.opt.backspace = { "indent", "eol", "start" }

-- CLIPBOARD
vim.opt.clipboard = "unnamed"          -- use system clipboard

-- MOUSE
vim.opt.mouse = "a"                    -- enable mouse

-- COLOR SCHEME
vim.cmd.colorscheme "tokyonight"

-- ARROW-KEY DISABLING
vim.keymap.set("n", "<Left>",  ":echo 'Use h'<CR>")
vim.keymap.set("n", "<Right>", ":echo 'Use l'<CR>")
vim.keymap.set("n", "<Up>",    ":echo 'Use k'<CR>")
vim.keymap.set("n", "<Down>",  ":echo 'Use j'<CR>")

vim.keymap.set("i", "<Left>",  "<ESC>:echo 'Use h'<CR>")
vim.keymap.set("i", "<Right>", "<ESC>:echo 'Use l'<CR>")
vim.keymap.set("i", "<Up>",    "<ESC>:echo 'Use k'<CR>")
vim.keymap.set("i", "<Down>",  "<ESC>:echo 'Use j'<CR>")

-- PASTE MODE TOGGLE
vim.keymap.set("n", "<leader>p", function()
  vim.opt.paste = not vim.opt.paste:get()
  print("paste = " .. (vim.opt.paste:get() and "ON" or "OFF"))
end)

-- LUALINE SETUP
require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
  }
})
