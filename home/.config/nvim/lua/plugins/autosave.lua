return {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
        condition = function(buf)
            local path = vim.api.nvim_buf_get_name(buf)
            -- never autosave the editor's own config
            return path ~= "" and path:find(vim.fn.expand("~/.config/nvim"), 1, true) == nil
        end,
    },
}
