local KEY_LUT = {
    x = "x",
    y = "y",
    z = "z",
    r = "x",
    g = "y",
    b = "z",
    h = "x",
    s = "y",
    l = "z",
}

---@class Vec3
---@field x number
---@field y number
---@field z number
---@field r number Alias for the `x` component
---@field g number Alias for the `y` component
---@field b number Alias for the `z` component
---@field h number Alias for the `x` component
---@field s number Alias for the `y` component
---@field l number Alias for the `z` component
local Vec3 = {}
local mt = {
    __index = function(self, key)
        if KEY_LUT[key] then
            return self[KEY_LUT[key]]
        end
        return Vec3[key]
    end,
    __newindex = function(self, key, value)
        if KEY_LUT[key] then
            self[KEY_LUT[key]] = value
        end
        Vec3[key] = value
    end,
    __add = function(...)
        return Vec3.__add(...)
    end,
    __sub = function(...)
        return Vec3.__sub(...)
    end,
    __mul = function(...)
        return Vec3.__mul(...)
    end,
    __div = function(...)
        return Vec3.__div(...)
    end,
    __unm = function(...)
        return Vec3.__unm(...)
    end,
    __eq = function(...)
        return Vec3.__eq(...)
    end,
    __tostring = function(...)
        return Vec3.__tostring(...)
    end,
}

---Create a new vector with the given component values.
---@param x? number
---@param y? number
---@param z? number
---@return Vec3
function Vec3:new(x, y, z)
    local o = {
        x = x or 0,
        y = y or 0,
        z = z or 0,
    }
    setmetatable(o, mt)
    return o
end

---@param lhs Vec3
---@param rhs Vec3
---@return Vec3
function Vec3.__add(lhs, rhs)
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        error("vec3: invalid operands for addition")
    end
    return Vec3:new(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
end

---@param lhs Vec3
---@param rhs Vec3
---@return Vec3
function Vec3.__sub(lhs, rhs)
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        error("vec3: invalid operands for subtraction")
    end
    return Vec3:new(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
end

---@param lhs number
---@param rhs number
---@return Vec3
function Vec3.__mul(lhs, rhs)
    local vec, scalar
    if type(lhs) == "table" and type(rhs) == "number" then
        vec = lhs
        scalar = rhs
    elseif type(lhs) == "number" and type(rhs) == "table" then
        vec = rhs
        scalar = lhs
    else
        error("vec3: invalid operands for scalar multiplication")
    end

    return Vec3:new(vec.x * scalar, vec.y * scalar, vec.z * scalar)
end

---@param lhs number
---@param rhs number
---@return Vec3
function Vec3.__div(lhs, rhs)
    local vec, scalar
    if type(lhs) == "table" and type(rhs) == "number" then
        vec = lhs
        scalar = rhs
    elseif type(lhs) == "number" and type(rhs) == "table" then
        vec = rhs
        scalar = lhs
    else
        error("vec3: invalid operands for scalar multiplication")
    end

    return Vec3:new(vec.x / scalar, vec.y / scalar, vec.z / scalar)
end

---@param self Vec3
---@return Vec3
function Vec3.__unm(self)
    return Vec3:new(-self.x, -self.y, -self.z)
end

---@param lhs Vec3
---@param rhs Vec3
---@return boolean
function Vec3.__eq(lhs, rhs)
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        error("vec3: invalid operands for equality")
    end
    return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z
end

local function fmt_component(value)
    return string.format("%f", value):gsub("(%.%d-)0+$", "%1"):gsub("%.$", "")
end

---@param self Vec3
---@return string
function Vec3.__tostring(self)
    return string.format(
        "[%s, %s, %s]",
        fmt_component(self.x),
        fmt_component(self.y),
        fmt_component(self.z)
    )
end

return Vec3
