local const = require("colorful.const")

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
local Vector3 = {}
local mt = {
    __index = function(self, key)
        if const.VEC_COMPONENTS[key] then
            return self[const.VEC_COMPONENTS[key]]
        end
        return Vector3[key]
    end,
    __newindex = function(self, key, value)
        if const.VEC_COMPONENTS[key] then
            self[const.VEC_COMPONENTS[key]] = value
        end
        Vector3[key] = value
    end,
    __add = function(...)
        return Vector3.__add(...)
    end,
    __sub = function(...)
        return Vector3.__sub(...)
    end,
    __mul = function(...)
        return Vector3.__mul(...)
    end,
    __div = function(...)
        return Vector3.__div(...)
    end,
    __unm = function(...)
        return Vector3.__unm(...)
    end,
    __eq = function(...)
        return Vector3.__eq(...)
    end,
    __tostring = function(...)
        return Vector3.__tostring(...)
    end,
}

---Create a new vector with the given component values.
---@private
---@param x number
---@param y number
---@param z number
---@return Vec3
function Vector3:_ctor(x, y, z)
    local o = {
        x = x,
        y = y,
        z = z,
    }
    setmetatable(o, mt)
    return o
end

---@param lhs Vec3
---@param rhs Vec3
---@return Vec3
function Vector3.__add(lhs, rhs)
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        error("vec3: invalid operands for addition")
    end
    return Vector3:_ctor(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
end

---@param lhs Vec3
---@param rhs Vec3
---@return Vec3
function Vector3.__sub(lhs, rhs)
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        error("vec3: invalid operands for subtraction")
    end
    return Vector3:_ctor(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
end

---@param lhs number
---@param rhs number
---@return Vec3
function Vector3.__mul(lhs, rhs)
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

    return Vector3:_ctor(vec.x * scalar, vec.y * scalar, vec.z * scalar)
end

---@param lhs number
---@param rhs number
---@return Vec3
function Vector3.__div(lhs, rhs)
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

    return Vector3:_ctor(vec.x / scalar, vec.y / scalar, vec.z / scalar)
end

---@param self Vec3
---@return Vec3
function Vector3.__unm(self)
    return Vector3:_ctor(-self.x, -self.y, -self.z)
end

---@param lhs Vec3
---@param rhs Vec3
---@return boolean
function Vector3.__eq(lhs, rhs)
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        error("vec3: invalid operands for equality")
    end
    return lhs.x == rhs.x and lhs.y == rhs.y and lhs.z == rhs.z
end

local function fmt_component(value)
    -- remove trailing zeroes from float format
    return string.format("%f", value):gsub("(%.%d-)0+$", "%1"):gsub("%.$", "")
end

---@param self Vec3
---@return string
function Vector3.__tostring(self)
    return string.format(
        "[%s, %s, %s]",
        fmt_component(self.x),
        fmt_component(self.y),
        fmt_component(self.z)
    )
end

setmetatable(Vector3, {
    __call = function(self, ...)
        local args = { ... }
        if #args == 0 then
            return self:_ctor(0, 0, 0)
        end
        if #args == 1 then
            return self:_ctor(args[1], args[1], args[1])
        end
        if #args == 3 then
            return self:_ctor(...)
        end

        error("Vec3 constructor requires 0, 1, or 3 arguments")
    end,
})

---@alias Vec3.ctor1 fun(scalar?: number): Vec3
---@alias Vec3.ctor3 fun(x: number, y: number, z: number): Vec3
---@type Vec3|Vec3.ctor1|Vec3.ctor3
local Vec3 = Vector3

return Vec3
