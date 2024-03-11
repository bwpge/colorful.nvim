local const = require("colorful.const")
local u = require("colorful.utils")
local Vec3 = require("colorful.vec3")

---@class Color
---@field private _rgb Vec3
---@field private _hsl Vec3
---@field r number Red component
---@field g number Green component
---@field b number Blue component
---@field h number Hue component
---@field s number Saturation component
---@field l number Lightness component
local Color = {}
setmetatable(Color, {
    __call = function(cls, ...)
        local args = { ... }
        if #args == 0 then
            return cls.default()
        end
        if #args == 1 then
            return cls.parse(args[1])
        end
        if #args == 3 then
            return cls.new_rgb(...)
        end

        error("Color constructor requires 0, 1, or 3 arguments")
    end,
})

local mt = {
    __index = function(self, key)
        if const.RGB_COMPONENTS[key] then
            return self._rgb[key]
        end
        if const.HSL_COMPONENTS[key] then
            return self._hsl[key]
        end
        return Color[key]
    end,
    __newindex = function(self, key, value)
        if const.RGB_COMPONENTS[key] then
            self._rgb[key] = value
            self:_update_hsl()
        end
        if const.HSL_COMPONENTS[key] then
            self._hsl[key] = value
            self:_update_rgb()
        end
        Color[key] = value
    end,
    __eq = function(...)
        return Color.__eq(...)
    end,
    __tostring = function(self)
        return self:tostring()
    end,
}

---@alias ColorTable { _rgb: Vec3, _hsl: Vec3 }
---@alias ColorFormat "rgb"|"hsl"

---@private
---@param t? ColorTable
---@return Color
function Color._ctor(t)
    local o = t or { _rgb = Vec3(), _hsl = Vec3() }
    return setmetatable(o, mt)
end

---Create a new default (black) color.
---@return Color
function Color.default()
    return Color._ctor()
end

---Create a new color from RGB components.
---@param r number
---@param g number
---@param b number
---@return Color
function Color.new_rgb(r, g, b)
    for _, val in ipairs({ r, g, b }) do
        if not u.in_range(val, 0, 1) then
            error("RGB component values must be in the range [0, 1]")
        end
    end

    local rgb = Vec3(r, g, b)
    local hsl = Vec3(u.rgb_to_hsl(rgb:unpack()))
    return Color._ctor({ _rgb = rgb, _hsl = hsl })
end

---Create a new color from HSL components.
---@param h number
---@param s number
---@param l number
---@return Color
function Color.new_hsl(h, s, l)
    for _, val in ipairs({ h, s, l }) do
        if not u.in_range(val, 0, 1) then
            error("HSL component values must be in the range [0, 1]")
        end
    end

    local hsl = Vec3(h % 1, s, l)
    local rgb = Vec3(u.hsl_to_rgb(hsl:unpack()))
    return Color._ctor({ _rgb = rgb, _hsl = hsl })
end

---Parses a color from either a string or decimal representation.
---
---This method tries parsing RGB representations first, then tries HSL representations. If neither
---format succeeds, and error is thrown.
---
---See `Color.parse_rgb` and `Color.parse_hsl` for specifics around valid forms.
---@param value string|number
---@return Color
function Color.parse(value)
    local ok, result
    ok, result = pcall(Color.parse_rgb, value)
    if ok then
        return result
    end

    -- a number cannot be used for HSL parsing
    if type(value) ~= "string" then
        error(string.format(
            "`%s` is not a valid RGB color, and a \z
            string value is required for HSL formats",
            value
        ))
    end
    ok, result = pcall(Color.parse_hsl, value)
    if ok then
        return result
    end

    error(string.format("`%s` is not a valid color representation", value))
end

---Parses a color from a string or number.
---
--- - Strings must have the form `#RGB` or `#RRGGBB`
--- - Numbers must be decimal representations of the above hexadecimal forms
---   (e.g., `1194684` for `#123abc`, or `1122867` for `#123`)
---@param value string|number
---@return Color
function Color.parse_rgb(value)
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
        error(string.format("`%s` is not a valid color", s))
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

    return Color.new_rgb(r, g, b)
end

---Parses a color from a string with the form `hsl(H, S, L)`.
---
--- - `H`: degrees in the range [0, 360)
--- - `S`: percentage in the range [0, 100], with optional `%` sign
--- - `L`: same as `S`
---
---The `H` value can have the `deg` suffix like in CSS (e.g., `155deg`), and commas between
---components are optional.
---@param s string
---@return Color
function Color.parse_hsl(s)
    local str = s:gsub("(hsl%(%d+)deg", "%1")
    local hsl = { str:match("^hsl%((%d+),?%s+(%d+)%%?,?%s+(%d+)%%?%)$") }

    if #hsl ~= 3 then
        error(string.format("`%s` is not a valid color", s))
    end
    for idx, v in ipairs(hsl) do
        hsl[idx] = tonumber(v)
    end

    if hsl[1] > 360 then
        error(string.format("`%s` has an invalid hue (`%s` is out of range)", s, hsl[1]))
    end
    if hsl[2] > 100 then
        error(string.format("`%s` has an invalid saturation (`%s` is out of range)", s, hsl[2]))
    end
    if hsl[3] > 100 then
        error(string.format("`%s` has an invalid lightness (`%s` is out of range)", s, hsl[3]))
    end

    return Color.new_hsl((hsl[1] / 360), hsl[2] / 100, hsl[3] / 100)
end

---Returns whether or not the input object is a `Color`.
---@param obj any
---@return boolean
function Color.is_color(obj)
    if type(obj) ~= "table" then
        return false
    end
    return getmetatable(obj) == mt
end

---@private
---@param lhs Color
---@param rhs Color
---@return boolean
function Color.__eq(lhs, rhs)
    if not Color.is_color(lhs) or not Color.is_color(rhs) then
        error("invalid operands for evaluating Color equality", 2)
    end

    -- NOTE: we might want to also check HSL values, but they should always be in sync
    return lhs._rgb == rhs._rgb
end

---Returns a copy of this color.
---
---Example:
---
---```lua
---local c1 = Color(0.5, 0.1, 0.2)
---local c2 = c1:copy()
---assert(c1 == c2)
---
---c2.r = 0
---assert(c1 ~= c2)
---```
---@return Color
function Color:copy()
    local o = { _rgb = self._rgb:copy(), _hsl = self._hsl:copy() }
    return Color._ctor(o)
end

---Returns this color as a hexadecimal string with the form `#RRGGBB`.
---@return string
function Color:to_rgb_str()
    local r = u.round(self.r * 255)
    local g = u.round(self.g * 255)
    local b = u.round(self.b * 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

---Returns this color as an HSL string with the form `hsl(H, S, L)`.
---
---The `H` value is printed as degrees [0, 360), and the `S`/`L` components are printed as
---percentages [0, 100] with a `%` sign.
---@return string
function Color:to_hsl_str()
    -- NOTE: hue should always be in the range [0, 1), so the degrees should
    -- never be >=360. however if we have bugs elsewhere in the code, this
    -- might result in a bad output
    local h = u.round(self.h * 360)
    local s = u.round(self.s * 100)
    local l = u.round(self.l * 100)
    return string.format("hsl(%d, %d%%, %d%%)", h, s, l)
end

---Returns this color as a string, with an optional `format`:
---
--- - `rgb`: Returns `self:to_rgb_str()`
--- - `hsl`: Returns `self:to_hsl_str()`
---
---If no `format` is provided, this is equivalent to calling `tostring(Color)`.
---@param format? ColorFormat Which color format to use (default: rgb)
---@return string
function Color:tostring(format)
    format = format or "rgb"
    if format == "rgb" then
        return self:to_rgb_str()
    end
    return self:to_hsl_str()
end

---Modifies the RGB component values by the given amounts.
---
---Any adjustments values are valid, but RGB color components are clamped to `[0, 1]`.
---
---Prefer using this method if making multiple adjustments to RGB values to avoid unnecessary
---HSL value updates (triggered by assigning values to RGB fields).
---@param r number
---@param g number
---@param b number
---@return Color self Reference to this object for method chaining
function Color:adjust_rgb(r, g, b)
    self._rgb.r = u.clamp(self._rgb.r + r, 0, 1)
    self._rgb.g = u.clamp(self._rgb.g + g, 0, 1)
    self._rgb.b = u.clamp(self._rgb.b + b, 0, 1)
    self:_update_hsl()

    return self
end

---Modifies the HSL component values by the given amounts.
---
---Any adjustments values are valid, but HSL color components are clamped to `[0, 1]`.
---
---Prefer using this method if making multiple adjustments to HSL values to avoid unnecessary
---RGB value updates (triggered by assigning values to HSL fields).
---@param h number
---@param s number
---@param l number
---@return Color self Reference to this object for method chaining
function Color:adjust_hsl(h, s, l)
    self._hsl.h = u.clamp(self._hsl.h + h, 0, 1) % 1
    self._hsl.s = u.clamp(self._hsl.s + s, 0, 1)
    self._hsl.l = u.clamp(self._hsl.l + l, 0, 1)
    self:_update_rgb()

    return self
end

---Applies a linear blend between this color and `other`, where `amount` is used from this color and
---`1 - amount` is used of `other`.
---
---Any `amount` is valid, but it will be clamped to `[0, 1]` before blending.
---@param other Color
---@param amount number
---@return Color self Reference to this object for method chaining
function Color:blend(other, amount)
    amount = u.clamp(amount, 0, 1)
    local f = 1.0 - amount
    local r1, g1, b1 = self._rgb:unpack()
    local r2, g2, b2 = other._rgb:unpack()

    self._rgb.r = u.clamp((amount * r1) + (f * r2), 0, 1)
    self._rgb.g = u.clamp((amount * g1) + (f * g2), 0, 1)
    self._rgb.b = u.clamp((amount * b1) + (f * b2), 0, 1)
    self:_update_hsl()

    return self
end

---Add `amount` to the hue angle. A positive `amount` rotates clockwise (R->G->B), a negative
---`amount` rotates counter-clockwise (B->G->R).
---
---Any `amount` is valid, but the result is stored modulus 1 to allow the hue to rotate around.
---
---Consider using `Color:adjust_hsl` if making multiple HSL adjustments to avoid unnecessary RGB
---updates.
---@param amount number
---@return Color self Reference to this object for method chaining
function Color:rotate(amount)
    self.h = (self._hsl.h + amount) % 1
    return self
end

---Add `amount` to the saturation. Saturates the color with a positive value, desaturates with a
---negative value.
---
---Any `amount` is valid, but the result is clamped to the range [0, 1].
---
---Consider using `Color:adjust_hsl` if making multiple HSL adjustments to avoid unnecessary RGB
---updates.
---@param amount number Any floating point value
---@return Color self Reference to this object for method chaining
function Color:saturate(amount)
    self.s = u.clamp(self.s + amount, 0, 1)
    return self
end

---Add `amount` to the lightness. Lightens the color with a positive value, darkens with a negative
---value.
---
---Any `amount` is valid, but the result is clamped to the range [0, 1].
---
---Consider using `Color:adjust_hsl` if making multiple HSL adjustments to avoid unnecessary RGB
---updates.
---@param amount number Any floating point value
---@return Color self Reference to this object for method chaining
function Color:lighten(amount)
    self.l = u.clamp(self.l + amount, 0, 1)
    return self
end

---Returns unpacked RGB or HSL components.
--
---@param format? ColorFormat Which components to unpack (default: rgb)
---@return number, number, number
function Color:unpack(format)
    format = format or "rgb"
    if format == "rgb" then
        return self._rgb:unpack()
    end
    return self._hsl:unpack()
end

---Update the inner RGB components from the HSL components.
---@private
function Color:_update_rgb()
    self._rgb.r, self._rgb.g, self._rgb.b = u.hsl_to_rgb(self._hsl:unpack())
end

---Update the inner HSL components from the RGB components.
---@private
function Color:_update_hsl()
    self._hsl.h, self._hsl.s, self._hsl.l = u.rgb_to_hsl(self._rgb:unpack())
end

---Create a new default (black) color. Equivalent to calling `Color.default()`.
---@alias Color.ctor0 fun(): Color

---Create a new color by parsing a string or number. Equivalent to calling `Color.parse(value)`.
---@alias Color.ctor1 fun(value: string|number): Color

---Create a new color from RGB components. Equivalent to calling `Color.new_rgb(r, g, b)`.
---
---There is no call syntax for HSL components (use `Color:new_hsl` if HSL is needed).
---@alias Color.ctor_rgb fun(r: number, g: number, b: number): Color

---@type Color|Color.ctor0|Color.ctor1|Color.ctor_rgb
local C = Color

return C
