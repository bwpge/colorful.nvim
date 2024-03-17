local Color = require("colorful.color")
local const = require("colorful.const")

---@alias ColorField "fg"|"bg"|"sp"

---@class Highlight
---@field fg? Color
---@field bg? Color
---@field sp? Color
---@field blend? boolean
---@field bold? boolean
---@field standout? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field underdouble? boolean
---@field underdotted? boolean
---@field underdashed? boolean
---@field strikethrough? boolean
---@field italic? boolean
---@field reverse? boolean
---@field nocombine? boolean
---@field link? boolean
---@field default? boolean
---@field ctermfg? boolean
---@field ctermbg? boolean
---@field cterm? boolean
local Highlight = {}
setmetatable(Highlight, {
    __call = function(cls, ...)
        local args = { ... }
        if #args == 0 then
            return Highlight.new()
        end
        if #args > 3 then
            error("Highlight constructor takes at most 3 arguments", 2)
        end

        return cls.from_group(...)
    end,
})

local mt = {
    __index = Highlight,
}

---Creates a new `Highlight` with the given table values.
---
---Invalid keys are ignored.
---@param t? table
function Highlight.new(t)
    t = t or {}
    local hl = {}

    for alias, key in pairs(const.HL_COLOR_KEYS) do
        local value = t[alias]
        if value then
            if Color.is_color(value) then
                hl[key] = value
            else
                hl[key] = Color.parse(value)
            end
        end
    end

    hl.blend = t.blend
    hl.bold = t.bold
    hl.standout = t.standout
    hl.underline = t.underline
    hl.undercurl = t.undercurl
    hl.underdouble = t.underdouble
    hl.underdotted = t.underdotted
    hl.underdashed = t.underdashed
    hl.strikethrough = t.strikethrough
    hl.italic = t.italic
    hl.reverse = t.reverse
    hl.nocombine = t.nocombine
    hl.link = t.link
    hl.default = t.default
    hl.ctermfg = t.ctermfg
    hl.ctermbg = t.ctermbg
    hl.cterm = t.cterm

    ---@type Highlight
    return setmetatable(hl, mt)
end

---Returns whether or not the given highlight group `name` exists.
---
---This function is a simple wrapper over `vim.fn.hlexists`.
---@param name string
---@return boolean
function Highlight.exists(name)
    return vim.fn.hlexists(name) == 1
end

---Returns the result of `nvim_get_hl` as a `Highlight` object.
---
---Throws an error if the group name does not exist.
---@param name string
---@param ns_id? integer
---@param link? boolean
---@return Highlight
function Highlight.from_group(name, ns_id, link)
    if not Highlight.exists(name) then
        error(string.format("Highlight group `%s` does not exist", name))
    end

    local hl = vim.api.nvim_get_hl(ns_id or 0, { name = name, link = link or false })
    return Highlight.new(hl)
end

---Calls `nvim_get_hl` until reaching a highlight group that is not linked and returns the name.
---
---Returns `nil` if the highlight group does not exist.
---@param name string
---@param ns_id? integer
function Highlight.resolve_link(name, ns_id)
    local current = name
    while true do
        -- avoid creating a group that doesn't exist
        if not Highlight.exists(current) then
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

---@param field? ColorField
---@param name? string
---@param ... string?
---@return Color?
local function get_color_field(field, name, ...)
    if not name then
        local hl
        if Highlight.exists("Normal") then
            hl = Highlight("Normal")
        end

        if not hl or not hl[field] then
            return nil
        end
        return hl[field]
    end

    if Highlight.exists(name) then
        local hl = Highlight(name)
        if hl[field] then
            return hl[field]
        end
    end

    return get_color_field(field, ...)
end

---Returns the foreground color from the first highlight group that defines one.
---
---If none of the groups define a foreground color, `Normal` is used as a fallback. If `Nornmal` is
---not set or does not provide a color, `nil` is returned.
---@param name string?
---@param ... string?
---@return Color?
function Highlight.get_fg(name, ...)
    return get_color_field("fg", name, ...)
end

---Returns the background color from the first highlight group that defines one.
---
---If none of the groups define a background color, `Normal` is used as a fallback. If `Nornmal` is
---not set or does not provide a color, `nil` is returned.
---@param name string?
---@param ... string?
---@return Color?
function Highlight.get_bg(name, ...)
    return get_color_field("bg", name, ...)
end

---Applies the provided function to a copy of the color if it is not `nil`.
---@param field ColorField
---@param fn Color.MapFn
---@return Color?
function Highlight:map_color(field, fn)
    return Color.map(self[field], fn)
end

---Applies the provided function to a copy of the foreground color if it is not `nil`.
---@param fn Color.MapFn
---@return Color?
function Highlight:map_fg(fn)
    return self:map_color("fg", fn)
end

---Applies the provided function to a copy of the background color if it is not `nil`.
---@param fn Color.MapFn
---@return Color?
function Highlight:map_bg(fn)
    return self:map_color("bg", fn)
end

---Sets the given highlight group `name` with this highlight using `nvim_set_hl`.
---@param name string
---@param ns_id? integer
function Highlight:set(name, ns_id)
    local values = {}
    for k, v in pairs(self) do
        if Color.is_color(v) then
            ---@cast v Color
            values[k] = v:tostring()
        else
            values[k] = v
        end
    end

    vim.api.nvim_set_hl(ns_id or 0, name, values)
end

---Create a default (empty) `Highlight`.
---
---To create from a table, use `Highlight.new`.
---@alias Highlight.ctor0 fun(): Highlight

---Create a `Highlight` from a group name. Equivalent to calling `Highlight.from_group`.
---
---Throws an error if the group name does not exist.
---@alias Highlight.ctor3 fun(name: string, ns_id?: number, link?: boolean): Highlight

---@type Highlight|Highlight.ctor0|Highlight.ctor3
local HL = Highlight

return HL
