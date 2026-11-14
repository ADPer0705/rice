return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- 1. Explicitly configure image support
        image = {
            enabled = true,
            doc = {
                enabled = true,
                inline = true, -- Renders SVGs/images inside buffers/markdown
                float = true,  -- Renders images in floating windows/hover
            },
            formats = {
                "png", "jpg", "jpeg", "gif", "webp", "avif",
                "svg", -- Ensure SVG conversion is active
                "pdf",
            },
        },

        zen = { enabled = true },
        terminal = { enabled = true },

        explorer = {
            enabled = true,
            replace_netrw = true,
        },
        picker = {
            enabled = true,
            sources = {
                explorer = {
                    hidden = true,
                    ignored = true,
                }
            }
        },

        -- 2. Cleaned Bigfile Config
        bigfile = {
            enabled = true,
            size = 1.5 * 1024 * 1024,
            -- Don't trip bigfile logic on image/video formats
            ft = function(ctx)
                local media_exts = {
                    "svg", "png", "jpg", "jpeg", "gif", "webp", "avif", "ico", "bmp", "tiff",
                    "mp4", "mkv", "webm", "mov", "avi", "flv", "wmv", "m4v",
                    "mp3", "wav", "flac", "ogg", "m4a", "pdf",
                }
                local ext = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ctx.buf), ":e"):lower()
                if vim.tbl_contains(media_exts, ctx.ft) or vim.tbl_contains(media_exts, ext) then
                    return false
                end
            end,
        },

        notifier = { enabled = true },
        quickfix = { enabled = true },
        words = { enabled = true },
    },
    keys = {
        -- 1. Zen Mode
        { "<leader>zz", function() Snacks.zen() end,      desc = "Zen mode" },

        -- 2. Terminal
        { "<C-\\>",     function() Snacks.terminal() end, desc = "Toggle floating terminal", mode = { "n", "t" } },
        { "<leader>tf", function() Snacks.terminal() end, desc = "Floating terminal" },

        -- 3. Explorer (Focus-only behavior)
        {
            "<leader>e",
            function()
                for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
                    if picker:is_focused() then
                        return
                    else
                        picker:focus()
                        return
                    end
                end
                Snacks.explorer()
            end,
            desc = "Focus File Explorer",
        },

        -- 4. Pickers
        { "<leader>pf", function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = "Find files" },
        { "<C-p>",      function() Snacks.picker.git_files() end,                              desc = "Find git files" },
        { "<leader>ps", function() Snacks.picker.grep() end,                                   desc = "Grep string" },
        { "<leader>pb", function() Snacks.picker.buffers() end,                                desc = "List open buffers" },
        { "<leader>ph", function() Snacks.picker.help() end,                                   desc = "Search help tags" },
        { "<leader>pd", function() Snacks.picker.diagnostics() end,                            desc = "List diagnostics" },

        -- 5. Media & Git QoL Extras
        { "<leader>gB", function() Snacks.gitbrowse() end,                                     desc = "Open line in GitHub/Browser" },
        { "<leader>un", function() Snacks.notifier.show_history() end,                         desc = "Notification history" },
    },
}
