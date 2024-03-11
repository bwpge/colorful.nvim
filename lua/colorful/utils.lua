local M = {}

---Clamps a number between a minimum and maximum value.
---@param value number
---@param min number
---@param max number
---@return number
function M.clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

---Rounds a number to the nearest integer, or to the specified number of decimal places.
---@param value number The value to round
---@param places? integer Number of decimal places (must be a positive integer)
---@return integer
function M.round(value, places)
    if not places then
        return math.floor(value + 0.5)
    end

    if places < 1 then
        error("Cannot round to negative decimal places", 2)
    end
    local b = 10 ^ math.floor(places)
    return math.floor(value * b + 0.5) / b
end

---Returns the minimum and maximum values of the given arguments.
---@param x number
---@param ... number
---@return number min, number max
function M.minmax(x, ...)
    return math.min(x, ...), math.max(x, ...)
end

---Returns whether or not a number is in a given range.
---@param value number The value to be checked
---@param min number The minimum value, inclusive
---@param max number The maximum value, inclusive
---@return boolean
function M.in_range(value, min, max)
    return value >= min and value <= max
end

---Converts RGB values to HSL.
---
---Components must be normalized to floating point values in the range [0, 1].
---
---Adapted from https://github.com/EmmanuelOga/columns/blob/836312be76b85b7f85e0cb2c31f5f22624c62d3e/utils/color.lua
---It seems this implementation originated from: https://stackoverflow.com/a/9493060
---@param r number The normalized red component
---@param g number The normalized green component
---@param b number The normalized blue component
---@return number, number, number
function M.rgb_to_hsl(r, g, b)
    for _, component in ipairs({ r, g, b }) do
        if not M.in_range(component, 0, 1) then
            error("RGB components must be normalized to the range [0-1]", 2)
        end
    end

    local h, s, l
    local min, max = M.minmax(r, g, b)
    l = (max + min) / 2

    -- achromatic
    if max == min then
        return 0, 0, l
    end

    local chroma = max - min
    if l > 0.5 then
        s = chroma / (2 - max - min)
    else
        s = chroma / (max + min)
    end
    if max == r then
        h = (g - b) / chroma
        if g < b then
            h = h + 6
        end
    elseif max == g then
        h = (b - r) / chroma + 2
    elseif max == b then
        h = (r - g) / chroma + 4
    end
    h = h / 6

    return h, s, l
end

---Converts HSL values to RGB.
---
---Components must be normalized to floating point values in the range [0, 1].
---
---Adapted from https://github.com/EmmanuelOga/columns/blob/836312be76b85b7f85e0cb2c31f5f22624c62d3e/utils/color.lua
---It seems this implementation originated from: https://stackoverflow.com/a/9493060
---@param h number
---@param s number
---@param l number
---@return number, number, number
function M.hsl_to_rgb(h, s, l)
    for _, component in ipairs({ h, s, l }) do
        if not M.in_range(component, 0, 1) then
            error("HSL components must be normalized to the range [0-1]", 2)
        end
    end

    -- achromatic
    if s == 0 then
        return l, l, l
    end

    local function hue_to_rgb(p, q, t)
        if t < 0 then
            t = t + 1
        end
        if t > 1 then
            t = t - 1
        end
        if t < 1 / 6 then
            return p + (q - p) * 6 * t
        end
        if t < 1 / 2 then
            return q
        end
        if t < 2 / 3 then
            return p + (q - p) * (2 / 3 - t) * 6
        end
        return p
    end

    local q
    if l < 0.5 then
        q = l * (1 + s)
    else
        q = l + s - l * s
    end
    local p = 2 * l - q

    local r, g, b
    r = hue_to_rgb(p, q, h + 1 / 3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1 / 3)

    return r, g, b
end

return M
