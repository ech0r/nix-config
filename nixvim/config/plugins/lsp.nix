{
    plugins.lsp = {
        enable = true;
        servers = {
            rust_analyzer = {
                enable = true;
                installRustc = false;
                installCargo = false;
            };
            texlab.enable = true;
            gopls.enable = true;
            dockerls.enable = true;
            bashls.enable = true;
            nil_ls.enable = true;
            lua_ls.enable = true;
        };
    };
    plugins.lsp-lines = {
      enable = true;
    };
}
