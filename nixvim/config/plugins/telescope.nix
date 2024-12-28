{
    plugins.web-devicons.enable = true;
    plugins.telescope = {
        enable = true;
        highlightTheme = "gruvbox";
        keymaps = {
            # Find files using Telescope command-line sugar.
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
            "<leader>fd" = "diagnostics";

            # FZF like bindings
            "<C-p>" = "git_files";
            "<leader>p" = "oldfiles";
            "<C-f>" = "live_grep";
            # search a path with find_files
            "<leader>fp" = {
              action = ''<cmd>require("telescope.builtin").find_files({ cwd = vim.fn.input("Enter path: ", vim.fn.getcwd()) })<CR>'';
            };
        };
        extensions = {
          fzf-native.enable = true;
        };
    };
}
