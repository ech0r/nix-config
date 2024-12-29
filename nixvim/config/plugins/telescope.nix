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
        };
        extensions = {
          fzf-native.enable = true;
        };
        luaConfig.pre = ''
          local search_path = function()
            local path = vim.fn.input("Enter path to search: ")
            require("telescope.builtin").find_files({search_dirs={path}})
          end
          vim.keymap.set('n', '<leader>fp', search_path)
        '';
    };
}
