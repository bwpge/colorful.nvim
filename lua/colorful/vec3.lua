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
    __add = function(self, ...)
        return self:__add(...)
    end,
    __sub = function(self, ...)
        return self:__sub(...)
    end,
    __mul = function(self, ...)
        return self:__mul(...)
    end,
    __div = function(self, ...)
        return self:__div(...)
    end,
    __unm = function(self)
        return self:__unm()
    end,
    __eq = function(self, ...)
        return self:__eq(...)
    end,
    __tostring = function(self)
        return self:__tostring()
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

---@private
---@param rhs Vec3
---@return Vec3
function Vec3:__add(rhs)
    return Vec3:new(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
end

---@param rhs Vec3
---@return Vec3
function Vec3:__sub(rhs)
    return Vec3:new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
end

---@param value number
---@return Vec3
function Vec3:__mul(value)
    if type(self) == "number" and type(value) == "table" then
        return Vec3:new(value.x * self, value.y * self, value.z * self)
    end
    if type(self) == "table" and type(value) == "number" then
        return Vec3:new(self.x * value, self.y * value, self.z * value)
    end

    error("vec3: invalid operand types for scalar multiplication")
end

---@param value number
---@return Vec3
function Vec3:__div(value)
    if type(self) == "table" and type(value) == "number" then
        return Vec3:new(self.x / value, self.y / value, self.z / value)
    end

    error("vec3: invalid operand types for scalar division")
end

---@return Vec3
function Vec3:__unm()
    return Vec3:new(-self.x, -self.y, -self.z)
end

---@param rhs Vec3
---@return boolean
function Vec3:__eq(rhs)
    return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z
end

---@return string
function Vec3:__tostring()
    return ("[%f, %f, %f]"):format(self.x, self.y, self.z)
end

return Vec3
