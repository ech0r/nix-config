{
    plugins.cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
            sources = [
                {name = "nvim_lsp";}
                {name = "path";}
                {
                    name = "buffer";
                    options.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
                }
                {name = "luasnip";}
            ];
            mapping = {
                "<C-Space>" = "cmp.mapping.complete()";
                "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                "<C-e>" = "cmp.mapping.close()";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";
                "<CR>" = "cmp.mapping.confirm({ select = true })";
                "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            };
        };

    };
}
