local u = require("colorful.utils")

---@class Color
---@field r number
---@field g number
---@field b number
local Color = {}
Color.__index = Color
Color.__tostring = function(self)
    return self:hex()
end

---Create a new color object.
---
---RGB components must be normalized to floating point values between 0-1.
---@param r number Normalized red component
---@param g number Normalized green component
---@param b number Normalized blue component
---@return Color
function Color:new(r, g, b)
    local o = {
        r = r,
        g = g,
        b = b,
    }
    for k, val in pairs(o) do
        if not u.in_range(val, 0, 1) then
            error(string.format("RGB component values must be between 0-1 (got %s=%f)", k, val))
        end
    end

    return setmetatable(o, self)
end

---Parses a color from a string or number.
---
--- - Strings must have the form `#RGB` or `#RRGGBB`
--- - Numbers must be decimal representations of the above hexadecimal forms
---   (e.g., `1194684` for `#123abc`, or `1122867` for `#123`)
---@param value string|number
---@return Color
function Color:parse(value)
    local s
    if type(value) == "string" then
        s = value
    elseif type(value) == "number" then
        s = string.format("#%06x", value)
    else
        error(string.format("Cannot parse a color from type `%s`", type(value)))
    end

    local val = s:match("^#%x%x%x%x%x%x$") or s:match("^#%x%x%x$")
    if not val then
        error(string.format("`%s` is not a valid hexadecimal color", s))
    end

    local color = {}
    if val:len() == 4 then
        color.r = (tonumber(val:sub(2, 2), 16) * 17) / 255
        color.g = (tonumber(val:sub(3, 3), 16) * 17) / 255
        color.b = (tonumber(val:sub(4, 4), 16) * 17) / 255
    else
        color.r = tonumber(val:sub(2, 3), 16) / 255
        color.g = tonumber(val:sub(4, 5), 16) / 255
        color.b = tonumber(val:sub(6, 7), 16) / 255
    end

    return setmetatable(color, self)
end

---Returns this color as a hexadecimal string with the form `#RRGGBB`.
---@return string
function Color:hex()
    local r = u.round(self.r * 255)
    local g = u.round(self.g * 255)
    local b = u.round(self.b * 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

---Returns this color as a tuple of HSL components.
---
---All components returned are normalized in the range [0, 1].
---@nodiscard
---@return number h, number s, number l Hue, saturation, and lightness components
function Color:hsl()
    return u.rgb_to_hsl(self.r, self.g, self.b)
end

---Applies a linear blend between this color and `rhs`, where `amount` is used
---from this color and `1 - amount` is used of `rhs`.
---@param rhs Color
---@param amount number A floating point value in the range [0, 1]
---@return Color
function Color:blend(rhs, amount)
    if amount > 1 or amount < 0 then
        error("blend amount must be in the range [0, 1]")
    end

    local f = 1.0 - amount
    self.r = u.clamp((amount * self.r) + (f * rhs.r), 0, 1)
    self.g = u.clamp((amount * self.g) + (f * rhs.g), 0, 1)
    self.b = u.clamp((amount * self.b) + (f * rhs.b), 0, 1)

    return self
end

---Lightens this color by adding `amount` to the lightness.
---
---This is somewhat computationally expensive, as the RGB components are converted to HSL
---to preserve the base hue and saturation.
---@param amount number A floating point value in the range [0, 1]
---@return Color
function Color:tint(amount)
    if not u.in_range(amount, 0, 1) then
        error("tint amount must be in the range [0, 1]")
    end

    local h, s, l = self:hsl()
    l = u.clamp(l + amount, 0, 1)
    self.r, self.g, self.b = u.hsl_to_rgb(h, s, l)

    return self
end

---Darkens this color by subtracting `amount` from the lightness.
---
---This is somewhat computationally expensive, as the RGB components are converted to HSL
---to preserve the base hue and saturation.
---@param amount number A floating point value in the range [0, 1]
---@return Color
function Color:shade(amount)
    if not u.in_range(amount, 0, 1) then
        error("shade amount must be in the range [0, 1]")
    end

    local h, s, l = self:hsl()
    l = u.clamp(l - amount, 0, 1)
    self.r, self.g, self.b = u.hsl_to_rgb(h, s, l)

    return self
end

return Color
