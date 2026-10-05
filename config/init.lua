vim.g.mapleader = " "

-- Machine-specific options from ~/.config/nvim/local.lua (untracked, see
-- templates/nvim-local.example.lua). Neovim version differences are detected instead.
local machine = { nerd_font = true }
local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.uv.fs_stat(local_config) then
    machine = vim.tbl_extend("force", machine, dofile(local_config))
end
local has_nvim_011 = vim.fn.has("nvim-0.11") == 1

-- LSP servers and their commands (commands are used with the 0.11+ vim.lsp.config API)
local lsp_cmds = {
    pyright = { "pyright-langserver", "--stdio" },
    lua_ls = { "lua-language-server" },
    ts_ls = { "typescript-language-server", "--stdio" },
    html = { "vscode-html-language-server", "--stdio" },
    cssls = { "vscode-css-language-server", "--stdio" },
    bashls = { "bash-language-server", "start" },
    jsonls = { "vscode-json-language-server", "--stdio" },
    yamlls = { "yaml-language-server", "--stdio" },
    clangd = { "clangd" },
}
local lsp_servers = machine.lsp_servers or vim.tbl_keys(lsp_cmds)

-- render-markdown callouts, rendered as plain titles when there is no Nerd Font
local plain_callouts = {}
for _, name in ipairs({
    "note", "tip", "important", "warning", "caution", "abstract", "summary", "tldr", "info",
    "todo", "hint", "success", "check", "done", "question", "help", "faq", "attention",
    "failure", "fail", "missing", "danger", "error", "bug", "example", "quote", "cite",
}) do
    plain_callouts[name] = { rendered = (name:gsub("^%l", string.upper)) }
end

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

    -- Treesitter (master: the default branch is now the incompatible "main" rewrite)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "markdown", "markdown_inline" },
            })
        end,
    },

    -- Markdown rendering in the buffer (raw text shown on the cursor line and in insert mode)
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = { "markdown" },
        opts = machine.nerd_font and {} or {
            heading = { icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " } },
            checkbox = {
                unchecked = { icon = "[ ] " },
                checked = { icon = "[x] " },
                custom = { todo = { rendered = "[-] " } },
            },
            callout = plain_callouts,
            link = { enabled = false },
            sign = { enabled = false },
        },
        keys = {
            { "<leader>m", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown rendering" },
        },
    },

    -- Telescope (latest needs nvim 0.11+, so pin the last compatible release on older versions)
    {
        "nvim-telescope/telescope.nvim",
        tag = not has_nvim_011 and "0.1.8" or nil,
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = vim.fn.executable("make") == 1 and vim.fn.executable("cc") == 1,
            },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    file_ignore_patterns = { "%.git/" },
                },
            })
            pcall(telescope.load_extension, "fzf")

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
        end,
    },

    -- LSP & Mason (v2 of all three needs nvim 0.11+, so stay on v1 on older versions)
    {
        "neovim/nvim-lspconfig",
        version = not has_nvim_011 and "^1.0.0" or nil,
    },
    {
        "williamboman/mason.nvim",
        version = not has_nvim_011 and "^1.0.0" or nil,
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
        version = not has_nvim_011 and "^1.0.0" or nil,
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = lsp_servers,
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
            require("dap-python").setup("debugpy-adapter")
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

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        if not vim.bo.modifiable then
            return
        end
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

vim.cmd.colorscheme "tokyonight"

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
})

-- Diagnostic keymaps (global: works for linter-only diagnostics too, not just LSP)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })
-- vim.diagnostic.jump is 0.11+; goto_prev/goto_next are its deprecated 0.10 equivalents
local function diagnostic_jump(count)
    if has_nvim_011 then
        vim.diagnostic.jump({ count = count, float = true })
    elseif count < 0 then
        vim.diagnostic.goto_prev({ float = true })
    else
        vim.diagnostic.goto_next({ float = true })
    end
end
vim.keymap.set('n', '[d', function() diagnostic_jump(-1) end, { noremap = true, silent = true })
vim.keymap.set('n', ']d', function() diagnostic_jump(1) end, { noremap = true, silent = true })

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

-- Debugging keybindings (NEW)
vim.keymap.set("n", "<leader>b", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Start/Continue debugging" })
vim.keymap.set("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step into" })
vim.keymap.set("n", "<leader>do", ":DapStepOver<CR>", { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", ":DapStepOut<CR>", { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Terminate debugging" })
vim.keymap.set("n", "<leader>dr", ":DapToggleRepl<CR>", { desc = "Toggle REPL" })

-- clangd header/source switch
local function switch_source_header()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })
    if #clients == 0 then
        vim.notify("clangd not attached to this buffer", vim.log.levels.WARN)
        return
    end
    local client = clients[1]
    local method = "textDocument/switchSourceHeader"
    local params = vim.lsp.util.make_text_document_params()
    local function handler(err, result)
        if err then
            vim.notify("clangd switch error: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
        end
        if not result then
            vim.notify("No corresponding header/source file found")
            return
        end
        vim.cmd("edit " .. vim.uri_to_fname(result))
    end
    -- Client methods take self from 0.11; on 0.10 request is a plain function field
    if has_nvim_011 then
        client:request(method, params, handler, 0)
    else
        client.request(method, params, handler, 0)
    end
end

vim.keymap.set("n", "<leader>h", switch_source_header, { desc = "Switch header/source (clangd)" })

require('lualine').setup({
    options = {
        icons_enabled = machine.nerd_font,
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
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
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

        local capabilities = cmp_nvim_lsp.default_capabilities()

        for _, name in ipairs(lsp_servers) do
            local config = {
                on_attach = on_attach,
                capabilities = capabilities,
            }
            if has_nvim_011 then
                config.cmd = lsp_cmds[name]
                config.root_markers = name == "clangd"
                    and { "compile_commands.json", ".git" }
                    or { ".git" }
                vim.lsp.config(name, config)
                vim.lsp.enable(name)
            else
                -- vim.lsp.config/enable are 0.11+; use nvim-lspconfig's classic setup API
                require("lspconfig")[name].setup(config)
            end
        end
    end,
})
