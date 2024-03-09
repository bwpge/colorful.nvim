local const = require("colorful.const")
local u = require("colorful.utils")
local Vec3 = require("colorful.vec3")

local function make_metatable(cls, lut)
    return {
        __index = function(self, key)
            if lut[key] then
                return self._[key]
            end
            return cls[key]
        end,
        __newindex = function(self, key, value)
            if lut[key] then
                self._[key] = value
            end
            cls[key] = value
        end,
        __tostring = function(self)
            return self:__tostring()
        end,
    }
end

---@class RGBColor
---@field private _ Vec3
---@field r number Red component in the range [0, 1]
---@field g number Green component in the range [0, 1]
---@field b number Blue component in the range [0, 1]
local RGBColor = {}
local RGBColor_mt = make_metatable(RGBColor, const.RGB_COMPONENTS)

---@class HSLColor
---@field private _ Vec3
---@field h number Hue component in the range [0, 1]
---@field s number Saturation component in the range [0, 1]
---@field l number Lightness component in the range [0, 1]
local HSLColor = {}
local HSLColor_mt = make_metatable(HSLColor, const.HSL_COMPONENTS)

---Create a new RGB color object.
---
---RGB components must be normalized in the range [0, 1].
---@private
---@param r number Normalized red component
---@param g number Normalized green component
---@param b number Normalized blue component
---@return RGBColor
---@nodiscard
function RGBColor:_ctor(r, g, b)
    for _, val in ipairs({ r, g, b }) do
        if not u.in_range(val, 0, 1) then
            error("RGB component values must be in the range [0, 1]")
        end
    end

    local o = { _ = Vec3(r, g, b) }
    return setmetatable(o, RGBColor_mt)
end

---Parses a color from a string or number.
---
--- - Strings must have the form `#RGB` or `#RRGGBB`
--- - Numbers must be decimal representations of the above hexadecimal forms
---   (e.g., `1194684` for `#123abc`, or `1122867` for `#123`)
---@param value string|number
---@return RGBColor
function RGBColor:parse(value)
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

    local r, g, b
    if val:len() == 4 then
        r = (tonumber(val:sub(2, 2), 16) * 17) / 255
        g = (tonumber(val:sub(3, 3), 16) * 17) / 255
        b = (tonumber(val:sub(4, 4), 16) * 17) / 255
    else
        r = tonumber(val:sub(2, 3), 16) / 255
        g = tonumber(val:sub(4, 5), 16) / 255
        b = tonumber(val:sub(6, 7), 16) / 255
    end

    return RGBColor:_ctor(r, g, b)
end

---Returns this color as a hexadecimal string with the form `#RRGGBB`.
---@return string
function RGBColor:hex()
    local r = u.round(self.r * 255)
    local g = u.round(self.g * 255)
    local b = u.round(self.b * 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

---Modifies the RGB component values by the given amounts.
---
---Values must be normalized in the range [-1, 1]. The result of adjustments
---are clamped to [0, 1].
---@param r number
---@param g number
---@param b number
---@return RGBColor self Reference to this object for method chaining
function RGBColor:adjust(r, g, b)
    for _, val in ipairs({ r, g, b }) do
        if not val or not u.in_range(val, -1, 1) then
            error("adjustment values must be numbers in the range [-1, 1]")
        end
    end

    self.r = u.clamp(self.r + r, 0, 1)
    self.g = u.clamp(self.g + g, 0, 1)
    self.b = u.clamp(self.b + b, 0, 1)

    return self
end

---Converts this color to an `RGBColor`.
---@return HSLColor color New `HSLColor` object
---@nodiscard
function RGBColor:hsl()
    local h, s, l = u.rgb_to_hsl(self.r, self.g, self.b)
    return HSLColor:_ctor(h, s, l)
end

---Applies a linear blend between this color and `rhs`, where `amount` is used
---from this color and `1 - amount` is used of `rhs`.
---@param rhs RGBColor
---@param amount number A floating point value in the range [0, 1]
---@return RGBColor
function RGBColor:blend(rhs, amount)
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
---This is somewhat computationally expensive, as the RGB components are converted to HSL to
---preserve the base hue and saturation, and then converted back to RGB. If you are making multiple
---adjustments to hue, saturation, or lightness, consider using `RGBColor:hsl()` to manipulate those
---values directly and then convert back with `HSLColor:rgb()`.
---@param amount number A floating point value in the range [0, 1]
---@return RGBColor self Reference to this object for method chaining
function RGBColor:lighten(amount)
    if not u.in_range(amount, 0, 1) then
        error("tint amount must be in the range [0, 1]")
    end

    local hsl = self:hsl()
    hsl.l = u.clamp(hsl.l + amount, 0, 1)
    self.r, self.g, self.b = u.hsl_to_rgb(hsl.h, hsl.s, hsl.l)

    return self
end

---Darkens this color by subtracting `amount` from the lightness.
---
---This is somewhat computationally expensive, as the RGB components are converted to HSL to
---preserve the base hue and saturation, and then converted back to RGB. If you are making multiple
---adjustments to hue, saturation, or lightness, consider using `RGBColor:hsl()` to manipulate those
---values directly and then convert back with `HSLColor:rgb()`.
---@param amount number A floating point value in the range [0, 1]
---@return RGBColor self Reference to this object for method chaining
function RGBColor:darken(amount)
    if not u.in_range(amount, 0, 1) then
        error("shade amount must be in the range [0, 1]")
    end

    local hsl = self:hsl()
    hsl.l = u.clamp(hsl.l - amount, 0, 1)
    self.r, self.g, self.b = u.hsl_to_rgb(hsl.h, hsl.s, hsl.l)

    return self
end

---@param self RGBColor
---@return string
function RGBColor.__tostring(self)
    return self:hex()
end

---Create a new HSL color object.
---
---HSL components must be normalized in the range [0, 1].
---@private
---@param h number Normalized hue value
---@param s number Normalized saturation value
---@param l number Normalized lightness value
---@return HSLColor
---@nodiscard
function HSLColor:_ctor(h, s, l)
    for _, val in ipairs({ h, s, l }) do
        if not u.in_range(val, 0, 1) then
            error("HSL component values must be in the range [0, 1]")
        end
    end

    local o = { _ = Vec3(h % 1, s, l) }
    return setmetatable(o, HSLColor_mt)
end

---Parses a color from a string with the form `hsl(H, S, L)`.
---
--- - `H`: degrees in the range [0, 360)
--- - `S`: percentage in the range [0, 100], with optional `%` sign
--- - `L`: same as `S`
---
---The `H` value can have the `deg` suffix like in CSS (e.g., `155deg`), and
--commas between components are optional.
---@param s string
---@return HSLColor
function HSLColor:parse(s)
    local str = s:gsub("(hsl%(%d+)deg", "%1")
    local hsl = { str:match("^hsl%((%d+),?%s+(%d+)%%?,?%s+(%d+)%%?%)$") }

    if #hsl ~= 3 then
        error(string.format("`%s` is not a valid HSL string", s))
    end
    for idx, v in ipairs(hsl) do
        hsl[idx] = tonumber(v)
    end

    if hsl[1] >= 360 then
        error(string.format("`%s` has an invalid hue (`%s` is out of range)", s, hsl[1]))
    end
    if hsl[2] > 100 then
        error(string.format("`%s` has an invalid saturation (`%s` is out of range)", s, hsl[2]))
    end
    if hsl[3] > 100 then
        error(string.format("`%s` has an invalid lightness (`%s` is out of range)", s, hsl[3]))
    end

    return HSLColor:_ctor(hsl[1] / 360, hsl[2] / 100, hsl[3] / 100)
end

---Converts this color to an `RGBColor`.
---@return RGBColor color New `RGBColor` object
---@nodiscard
function HSLColor:rgb()
    local r, g, b = u.hsl_to_rgb(self.h, self.s, self.l)
    return RGBColor:_ctor(r, g, b)
end

---Modifies the HSL component values by the given amounts.
---
---Values must be normalized in the range [-1, 1].
---
---The result of the hue adjustment is stored modulus 1 (to allow the hue to
---cycle around), and the result of the saturation/lightness adjustments are
---clamped to [0, 1].
---@param h number
---@param s number
---@param l number
---@return HSLColor self Reference to this object for method chaining
function HSLColor:adjust(h, s, l)
    for _, val in ipairs({ h, s, l }) do
        if not val or not u.in_range(val, -1, 1) then
            error("adjustment values must be numbers in the range [-1, 1]")
        end
    end

    self.h = (self.h + h) % 1
    self.s = u.clamp(self.s + s, 0, 1)
    self.l = u.clamp(self.l + l, 0, 1)

    return self
end

---@param self HSLColor
---@return string
function HSLColor.__tostring(self)
    -- NOTE: hue should always be in the range [0, 1), so the degrees should
    -- never be >=360. however if we have bugs elsewhere in the code, this
    -- might result in a bad output
    local h = u.round(self.h * 360)
    local s = u.round(self.s * 100)
    local l = u.round(self.l * 100)
    return string.format("hsl(%d, %d%%, %d%%)", h, s, l)
end

local mt = {
    __call = function(self, ...)
        local args = { ... }
        if #args == 0 then
            return self:_ctor(0)
        end
        return self:_ctor(...)
    end,
}
setmetatable(RGBColor, mt)
setmetatable(HSLColor, mt)

---@alias RGBColor.ctor0 fun(): RGBColor
---@alias RGBColor.ctor3 fun(r: number, g: number, g: number): RGBColor
---@type RGBColor|RGBColor.ctor0|RGBColor.ctor3
local RGB = RGBColor

---@alias HSLColor.ctor0 fun(): HSLColor
---@alias HSLColor.ctor3 fun(h: number, s: number, l: number): HSLColor
---@type HSLColor|HSLColor.ctor0|HSLColor.ctor3
local HSL = HSLColor

return {
    RGBColor = RGB,
    HSLColor = HSL,
}
