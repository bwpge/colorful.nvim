local Highlight = require("colorful.highlight")

local M = {}

---@alias HighlightTable table<string, table> | fun(): table<string, table>

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
    highlights = {},
    create_autocmd = true,
    apply_on_setup = true,
}

---@type ColorfulConfig
---@diagnostic disable-next-line: missing-fields
M.options = {}

local function apply_highlights()
    local t
    if type(M.options.highlights) == "function" then
        t = M.options.highlights()
    else
        t = M.options.highlights
        ---@cast t table<string, table>
    end

    for k, v in pairs(t) do
        Highlight.new(v):set(k)
    end
end

---Runs the plugin setup with user provided options.
---@param opts? ColorfulUserConfig
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.default_config, opts or {})

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
