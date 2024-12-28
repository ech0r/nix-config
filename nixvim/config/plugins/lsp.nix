{
    plugins.lsp = {
        enable = true;
        servers = {
            rust-analyzer = {
                enable = true;
                installRustc = false;
                installCargo = false;
            };
            texlab.enable = true;
            gopls.enable = true;
            dockerls.enable = true;
            bashls.enable = true;
            nil-ls.enable = true;
            lua-ls.enable = true;
        };
    };
    plugins.lsp-lines = {
      enable = true;
    };
}
