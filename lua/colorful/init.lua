local Highlight = require("colorful.highlight")

local M = {}

---@alias PatternTable table<string, table>
---@alias HighlightTable fun(): table<string, PatternTable>

---@class ColorfulConfig
---@field highlights HighlightTable
---@field create_autocmd boolean
---@field apply_on_setup boolean

---@class ColorfulUserConfig
---@field highlights? HighlightTable
---@field create_autocmd? boolean
---@field apply_on_setup? boolean

---@type ColorfulConfig
M.default_config = {
    highlights = function()
        return {}
    end,
    create_autocmd = true,
    apply_on_setup = true,
}

---@type ColorfulConfig
---@diagnostic disable-next-line: missing-fields
M.options = {}

local function set_hl_table(t)
    for k, v in pairs(t) do
        Highlight.new(v):set(k)
    end
end

local function apply_highlights()
    -- always apply `*` first, regardless of colorscheme
    local hls = M.options.highlights()
    if hls["*"] then
        set_hl_table(hls["*"])
        hls["*"] = nil
    end

    -- matches are not guaranteed in any particular order
    local colorscheme = vim.g.colors_name
    for name, t in pairs(hls) do
        if colorscheme:match(name) then
            set_hl_table(t)
        end
    end
end

---Runs the plugin setup with user provided options.
---@param opts? ColorfulUserConfig
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.default_config, opts or {})

    -- nothing to do if no highlights are provided
    if not M.options.highlights then
        return
    end

    if M.options.create_autocmd then
        vim.api.nvim_create_autocmd({ "ColorScheme" }, {
            callback = apply_highlights,
        })
    end
    if M.options.apply_on_setup then
        apply_highlights()
    end
end

return M
