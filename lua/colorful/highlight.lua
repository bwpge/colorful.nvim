local Color = require("colorful.color")

---@class Highlight
---@field fg? Color
---@field bg? Color
---@field special? Color
---@field link? string
---@field bold? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field underdouble? boolean
---@field underdotted? boolean
---@field underdashed? boolean
---@field inverse? boolean
---@field italic? boolean
---@field standout? boolean
---@field strikethrough? boolean
---@field altfont? boolean
---@field nocombine? boolean
---@field ctermfg? number|string
---@field ctermbg? number|string
---@field cterm? table
local Highlight = {}
Highlight.__index = Highlight

local COLOR_KEYS = {
    fg = "fg",
    foreground = "fg",
    bg = "bg",
    background = "bg",
    sp = "sp",
    special = "sp",
}

---Creates a new `Highlight` with the given table values.
---
---Invalid keys are ignored.
---@param t table
function Highlight:new(t)
    local hl = {}
    for alias, key in pairs(COLOR_KEYS) do
        local value = t[alias]
        if value then
            if type(value) == "number" then
                value = string.format("#%06x", value)
            end
            hl[key] = Color:parse(value)
        end
    end

    hl.link = t.link
    hl.bold = t.bold
    hl.underline = t.underline
    hl.undercurl = t.undercurl
    hl.underdouble = t.underdouble
    hl.underdotted = t.underdotted
    hl.underdashed = t.underdashed
    hl.inverse = t.inverse
    hl.italic = t.italic
    hl.standout = t.standout
    hl.strikethrough = t.strikethrough
    hl.altfont = t.altfont
    hl.nocombine = t.nocombine
    hl.ctermfg = t.ctermfg
    hl.ctermbg = t.ctermbg
    hl.cterm = t.cterm

    return setmetatable(hl, self)
end

---Returns the result of `nvim_get_hl` as a `Highlight` object.
---
---This function was adapted from a reddit comment, see:
---https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh
---@param name string
---@param ns_id? integer
---@param link? boolean
---@return Highlight?
function Highlight:from_group(name, ns_id, link)
    ---@diagnostic disable-next-line: undefined-field
    local ok, hl = pcall(vim.api.nvim_get_hl, ns_id or 0, { name = name, link = link or false })
    if not ok then
        return
    end

    return Highlight:new(hl)
end

---Sets the given highlight group with this `Highlight` using `nvim_set_hl`.
---@param name string
---@param ns_id? integer
function Highlight:set_group(name, ns_id)
    local values = {}
    for k, v in pairs(self) do
        if k == "fg" or k == "bg" or k == "sp" then
            values[k] = v:hex()
        else
            values[k] = v
        end
    end

    vim.api.nvim_set_hl(ns_id or 0, name, values)
end

---Calls `nvim_get_hl` until reaching a highlight group that is not linked and
---returns the name.
---
---Returns `nil` if the highlight group does not exist.
---@param name string
---@param ns_id? integer
function Highlight.resolve_link(name, ns_id)
    local current = name
    while true do
        -- avoid creating a group that doesn't exist
        if vim.fn.hlexists(current) ~= 1 then
            return nil
        end

        local next = vim.api.nvim_get_hl(ns_id or 0, { name = current, link = true })
        if not next.link then
            break
        end
        current = next.link
    end

    return current
end

return Highlight
