vim.g.mapleader = " "

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

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

    -- Telescope (pinned: latest requires nvim 0.11+, this machine is capped at 0.10)
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    file_ignore_patterns = { "%.git/" },
                },
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
        end,
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

    -- Formatting
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

    -- Linting
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                sh = { "shellcheck" },
                bash = { "shellcheck" },
                zsh = { "shellcheck" },
                python = { "ruff" },
                javascript = { "eslint" },
                typescript = { "eslint" },
            }

            vim.api.nvim_create_autocmd("BufWritePost", {
                callback = function()
                    lint.try_lint()
                end,
            })
        end
    },

    -- Debugging
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()

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

-- Diagnostic keymaps (global: works for linter-only diagnostics too, not just LSP)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true })

-- Disable arrow keys (vim training wheels)
vim.keymap.set("n", "<Left>", ":echo 'Use h'<CR>")
vim.keymap.set("n", "<Right>", ":echo 'Use l'<CR>")
vim.keymap.set("n", "<Up>", ":echo 'Use k'<CR>")
vim.keymap.set("n", "<Down>", ":echo 'Use j'<CR>")

vim.keymap.set("i", "<Left>", "<ESC>:echo 'Use h'<CR>")
vim.keymap.set("i", "<Right>", "<ESC>:echo 'Use l'<CR>")
vim.keymap.set("i", "<Up>", "<ESC>:echo 'Use k'<CR>")
vim.keymap.set("i", "<Down>", "<ESC>:echo 'Use j'<CR>")

-- Paste mode toggle
vim.keymap.set("n", "<leader>p", function()
    vim.opt.paste = not vim.opt.paste:get()
    print("paste = " .. (vim.opt.paste:get() and "ON" or "OFF"))
end)

-- Debugging keybindings
vim.keymap.set("n", "<leader>b", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Start/Continue debugging" })
vim.keymap.set("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step into" })
vim.keymap.set("n", "<leader>do", ":DapStepOver<CR>", { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", ":DapStepOut<CR>", { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Terminate debugging" })
vim.keymap.set("n", "<leader>dr", ":DapToggleRepl<CR>", { desc = "Toggle REPL" })

require('lualine').setup({
    options = {
        icons_enabled = false,
        theme = 'tokyonight',
    }
})
