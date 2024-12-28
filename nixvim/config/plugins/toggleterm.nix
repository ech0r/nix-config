{inputs, ...}: {
    plugins.toggleterm = {
        enable = true;
        settings = {
            open_mapping = "[[<C-t>]]";
            direction = "float";
            float_opts = {
              border = "curved";
            };
            start_in_insert = true;
            size = 100;
        };
    };
}
