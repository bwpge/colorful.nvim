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
    local hls = M.options.highlights()
    local merged = {}

    if hls["*"] then
        merged = vim.tbl_deep_extend("force", merged, hls["*"])
        hls["*"] = nil
    end

    local colorscheme = vim.g.colors_name or ""
    for name, t in pairs(hls) do
        if #name > 0 and colorscheme:match(name) then
            merged = vim.tbl_deep_extend("force", merged, t)
        end
    end

    set_hl_table(merged)
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
