-- Machine-specific Neovim options - not tracked by the dotfiles repo.
-- Copied once to ~/.config/nvim/local.lua by symlink.sh, then yours to edit freely.
return {
    -- false when the terminal font is not a Nerd Font (plain icons in lualine and markdown)
    nerd_font = true,
    -- LSP servers to install and enable; leave unset for the full default list
    -- lsp_servers = { "pyright" },
    -- git binary for diffview when the system git is older than 2.31
    -- diffview_git = vim.fn.expand("~/.local/git-env/bin/git"),
}
