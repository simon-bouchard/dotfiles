-- lazy.nvim bootstrap
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({
  -- UI & Appearance
  "nvim-lualine/lualine.nvim",
  "folke/tokyonight.nvim",
  "morhetz/gruvbox",
  "dracula/vim",
  "arcticicestudio/nord-vim",
  "joshdick/onedark.vim",
  "rose-pine/neovim",

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Telescope
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",

  -- LSP & Mason
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",  -- Changed from pylsp to pyright
          "lua_ls",
          "ts_ls",
          "html",
          "cssls",
          "bashls",
          "jsonls",
          "yamlls",
        },
        automatic_installation = true,
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")

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
    end
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",

  -- Formatting (NEW)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end
  },

  -- Linting (UPDATED)
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        sh = {"shellcheck"},
        bash = {"shellcheck"},
        zsh = {"shellcheck"},
        python = {"ruff"},  -- Changed from pylint to ruff
        javascript = {"eslint"},
        typescript = {"eslint"},
      }

      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          lint.try_lint()
        end,
      })
    end
  },

  -- Debugging (NEW)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup UI
      dapui.setup()

      -- Auto-open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup("python3")
    end
  },
})

-- ============================================================================
-- UI SETTINGS
-- ============================================================================

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/parsers")

vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.backspace = { "indent", "eol", "start" }

vim.opt.clipboard = "unnamed"
vim.opt.mouse = "a"

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

vim.cmd.colorscheme "tokyonight"
-- Other options: "gruvbox", "dracula", "nord", "onedark", "rose-pine"
-- Change above line to try different themes

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Disable arrow keys (vim training wheels)
vim.keymap.set("n", "<Left>",  ":echo 'Use h'<CR>")
vim.keymap.set("n", "<Right>", ":echo 'Use l'<CR>")
vim.keymap.set("n", "<Up>",    ":echo 'Use k'<CR>")
vim.keymap.set("n", "<Down>",  ":echo 'Use j'<CR>")

vim.keymap.set("i", "<Left>",  "<ESC>:echo 'Use h'<CR>")
vim.keymap.set("i", "<Right>", "<ESC>:echo 'Use l'<CR>")
vim.keymap.set("i", "<Up>",    "<ESC>:echo 'Use k'<CR>")
vim.keymap.set("i", "<Down>",  "<ESC>:echo 'Use j'<CR>")

-- Paste mode toggle
vim.keymap.set("n", "<leader>p", function()
  vim.opt.paste = not vim.opt.paste:get()
  print("paste = " .. (vim.opt.paste:get() and "ON" or "OFF"))
end)

-- Debugging keybindings (NEW)
vim.keymap.set("n", "<leader>b", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Start/Continue debugging" })
vim.keymap.set("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step into" })
vim.keymap.set("n", "<leader>do", ":DapStepOver<CR>", { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", ":DapStepOut<CR>", { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Terminate debugging" })
vim.keymap.set("n", "<leader>dr", ":DapToggleRepl<CR>", { desc = "Toggle REPL" })

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
  }
})

-- ============================================================================
-- LSP HANDLERS (runs after all plugins load)
-- ============================================================================

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format { async = true }
      end, bufopts)
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    end

    local capabilities = cmp_nvim_lsp.default_capabilities()

    local default_config = {
      on_attach = on_attach,
      capabilities = capabilities,
    }

    -- Setup each LSP server using vim.lsp.config
    local servers = {
      { name = "pyright", cmd = { "pyright-langserver", "--stdio" } },  -- Changed from pylsp
      { name = "lua_ls", cmd = { "lua-language-server" } },
      { name = "ts_ls", cmd = { "typescript-language-server", "--stdio" } },
      { name = "html", cmd = { "vscode-html-language-server", "--stdio" } },
      { name = "cssls", cmd = { "vscode-css-language-server", "--stdio" } },
      { name = "bashls", cmd = { "bash-language-server", "start" } },
      { name = "jsonls", cmd = { "vscode-json-language-server", "--stdio" } },
      { name = "yamlls", cmd = { "yaml-language-server", "--stdio" } },
    }

    for _, server in ipairs(servers) do
      vim.lsp.config(server.name, {
        cmd = server.cmd,
        root_markers = { ".git" },
        on_attach = default_config.on_attach,
        capabilities = default_config.capabilities,
      })
      vim.lsp.enable(server.name)
    end
  end,
})
