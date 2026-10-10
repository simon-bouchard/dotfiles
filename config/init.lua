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

-- which-key key labels as text when there is no Nerd Font (its defaults are Nerd Font glyphs)
local plain_keys = { C = "C-", M = "M-", D = "D-", S = "S-" }
for _, name in ipairs({
    "Up", "Down", "Left", "Right", "CR", "Esc", "NL", "BS", "Space", "Tab",
    "ScrollWheelDown", "ScrollWheelUp",
}) do
    plain_keys[name] = name .. " "
end
for i = 1, 12 do
    plain_keys["F" .. i] = "F" .. i
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
                ensure_installed = {
                    "markdown", "markdown_inline", "python", "lua", "bash", "c", "cpp",
                    "javascript", "typescript", "html", "css", "json", "yaml", "toml",
                    "vim", "vimdoc", "query",
                },
                highlight = { enable = true },
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
            local actions = require("telescope.actions")
            -- <C-s> for vertical split (matches oil): the terminal grabs <C-v> as paste
            local split_mappings = { ["<C-s>"] = actions.select_vertical }
            local builtin = require("telescope.builtin")
            -- File icons come from nvim-web-devicons; disable_devicons is a per-picker option
            local pickers = {}
            if not machine.nerd_font then
                for name in pairs(builtin) do
                    pickers[name] = { disable_devicons = true }
                end
            end
            telescope.setup({
                defaults = {
                    file_ignore_patterns = { "%.git/" },
                    mappings = { i = split_mappings, n = split_mappings },
                },
                pickers = pickers,
            })
            pcall(telescope.load_extension, "fzf")

            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
            vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
            vim.keymap.set("n", "<leader>f.", builtin.resume, { desc = "Resume last picker" })
            vim.keymap.set(
                "n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Search in file" }
            )
            vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
            vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Project diagnostics" })

            -- Fresh table per call: Telescope stores per-picker state in the opts it is given
            local function code_symbols()
                return { symbols = { "class", "function", "method" } }
            end
            vim.keymap.set("n", "<leader>fs", function()
                builtin.lsp_document_symbols(code_symbols())
            end, { desc = "Classes/functions in file" })
            vim.keymap.set(
                "n", "<leader>fa", builtin.lsp_document_symbols, { desc = "All symbols in file" }
            )
            vim.keymap.set("n", "<leader>fS", function()
                builtin.lsp_dynamic_workspace_symbols(code_symbols())
            end, { desc = "Classes/functions in project" })
            vim.keymap.set(
                "n", "<leader>fA", builtin.lsp_dynamic_workspace_symbols,
                { desc = "All symbols in project" }
            )
        end,
    },

    -- File explorer: directories open as editable buffers, :w applies renames/moves/deletes
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        lazy = false,
        opts = {
            columns = machine.nerd_font and { "icon" } or {},
            view_options = { show_hidden = true },
        },
        keys = {
            { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
        },
    },

    -- Keymap hints: pause after a prefix like <leader> to see the keys that can follow
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 800,
            spec = {
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>d", group = "debug" },
            },
            icons = machine.nerd_font and {} or { mappings = false, keys = plain_keys },
        },
    },

    -- Git: hunk signs, inline hunk diffs and blame (main needs nvim 0.11+, so pin on older)
    {
        "lewis6991/gitsigns.nvim",
        tag = not has_nvim_011 and "v2.1.0" or nil,
        config = function()
            local gitsigns = require("gitsigns")
            gitsigns.setup()

            local map = vim.keymap.set
            map("n", "]h", function() gitsigns.nav_hunk("next") end, { desc = "Next git hunk" })
            map("n", "[h", function() gitsigns.nav_hunk("prev") end, { desc = "Prev git hunk" })
            map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview git hunk" })
            map("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "Inline git hunk" })
            map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage git hunk" })
            map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset git hunk" })
            map("n", "<leader>gb", gitsigns.blame_line, { desc = "Blame line" })
            map("n", "<leader>gf", gitsigns.diffthis, { desc = "Diff file against index" })
        end,
    },

    -- Git: side-by-side diffs of the whole repo, branches and file history
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = {
            use_icons = machine.nerd_font,
            git_cmd = { machine.diffview_git or "git" },
        },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff working tree" },
            { "<leader>gm", "<cmd>DiffviewOpen origin/HEAD...HEAD<CR>", desc = "Diff branch vs main" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
            { "<leader>gl", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
            { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close diffview" },
        },
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
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    -- Tab: next menu item, else jump to the next snippet field, else a real tab
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.locally_jumpable(1) then
                            luasnip.jump(1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                })
            })
        end
    },
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
    },

    -- Formatting (NEW)
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "ruff_organize_imports", "ruff_format" },
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

vim.opt.undofile = true

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
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true, desc = "Show diagnostic" })
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
vim.keymap.set('n', '[d', function() diagnostic_jump(-1) end, { silent = true, desc = "Prev diagnostic" })
vim.keymap.set('n', ']d', function() diagnostic_jump(1) end, { silent = true, desc = "Next diagnostic" })

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
end, { desc = "Toggle paste mode" })

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
-- LSP SETUP (must run before the first buffer loads, or servers start without this config)
-- ============================================================================

-- Drop the 0.11+ default gr* maps: they duplicate the maps below and make gr wait for a 3rd key
for _, lhs in ipairs({ "grr", "gri", "gra", "grn", "grt" }) do
    pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, "x", "gra")

-- LspAttach fires for every client, however it was started (including mason-lspconfig)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { silent = true, buffer = args.buf, desc = desc })
        end
        map('gd', vim.lsp.buf.definition, "Go to definition")
        map('K', vim.lsp.buf.hover, "Hover documentation")
        map('gi', vim.lsp.buf.implementation, "Go to implementation")
        map('gr', require("telescope.builtin").lsp_references, "Find references")
        map('<leader>rn', vim.lsp.buf.rename, "Rename symbol")
        map('<leader>ca', vim.lsp.buf.code_action, "Code action")
        map('<leader>f', function() vim.lsp.buf.format { async = true } end, "Format buffer")
    end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, name in ipairs(lsp_servers) do
    local config = { capabilities = capabilities }
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
