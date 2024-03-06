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
---@param r integer Red channel value
---@param g integer Green channel value
---@param b integer Blue channel value
---@return Color
function Color:new(r, g, b)
    local o = {
        r = r,
        g = g,
        b = b,
    }
    for k, val in pairs(o) do
        if not u.in_range(val, 0, 255) then
            error(string.format("RGB channel values must be between 0-255 (got %s=%s)", k, val))
        end
    end

    return setmetatable(o, self)
end

---Parses a color from a string.
---@param s string A hexadecimal string with the form `#RGB` or `#RRGGBB`
---@return Color
function Color:parse(s)
    local value = s:match("^#%x%x%x%x%x%x$") or s:match("^#%x%x%x$")
    if not value then
        error(string.format("`%s` is not a valid hexadecimal color", s))
    end

    local color = {}
    if value:len() == 4 then
        color.r = (tonumber(value:sub(2, 2), 16) * 17)
        color.g = (tonumber(value:sub(3, 3), 16) * 17)
        color.b = (tonumber(value:sub(4, 4), 16) * 17)
    else
        color.r = tonumber(value:sub(2, 3), 16)
        color.g = tonumber(value:sub(4, 5), 16)
        color.b = tonumber(value:sub(6, 7), 16)
    end

    return setmetatable(color, self)
end

---Returns this color as a hexadecimal string with the form `#RRGGBB`.
---@return string
function Color:hex()
    return string.format("#%02x%02x%02x", self.r, self.g, self.b)
end

---Applies a linear blend between this color and `rhs`, where `amount` is used
---from this color and `1 - amount` is used of `rhs`.
---@param rhs Color
---@param amount number A floating point value between 0 and 1
---@return Color
function Color:blend(rhs, amount)
    if amount > 1 or amount < 0 then
        error("blend amount must be between 0 and 1")
    end

    local f = 1.0 - amount
    self.r = u.round(u.clamp((amount * self.r) + (f * rhs.r), 0, 255))
    self.g = u.round(u.clamp((amount * self.g) + (f * rhs.g), 0, 255))
    self.b = u.round(u.clamp((amount * self.b) + (f * rhs.b), 0, 255))

    return self
end

---Lightens the color by adding `amount * (255 - channel)` of each RGB channel.
---@param amount number A floating point value between 0 and 1
---@return Color
function Color:lighten(amount)
    if amount > 1 or amount < 0 then
        error("blend amount must be between 0 and 1")
    end

    local dr = amount * (255 - self.r)
    local dg = amount * (255 - self.g)
    local db = amount * (255 - self.b)
    self.r = u.round(u.clamp(self.r + dr, 0, 255))
    self.g = u.round(u.clamp(self.g + dg, 0, 255))
    self.b = u.round(u.clamp(self.b + db, 0, 255))

    return self
end

---Darkens the color by subtracting `amount * channel` of each RGB channel.
---@param amount number A floating point value between 0 and 1
---@return Color
function Color:darken(amount)
    if amount > 1 or amount < 0 then
        error("blend amount must be between 0 and 1")
    end

    self.r = u.round(u.clamp(self.r - (amount * self.r), 0, 255))
    self.g = u.round(u.clamp(self.g - (amount * self.g), 0, 255))
    self.b = u.round(u.clamp(self.b - (amount * self.b), 0, 255))

    return self
end

return Color
