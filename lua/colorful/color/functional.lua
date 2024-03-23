local Color = require("colorful.color")

-- there seems to be a race condition, where sometimes table.unpack
-- works fine, but other times it's a nil value. this was observed
-- when neovim is started with a file vs. no arguments or a directory
local _unpack = table.unpack or unpack

local M = {}

local function make_closure(cls, key)
    local fn = cls[key]
    if fn and type(fn) == "function" then
        return function(...)
            local args = { ... }
            return function(self)
                return fn(self, _unpack(args))
            end
        end
    end
    error(string.format("`%s` is not a valid Color method or function", key), 2)
end

---@param cls table
---@param t? table
---@return table
local function make_functional_index(cls, t)
    return setmetatable(t or {}, {
        __index = function(_, key)
            return make_closure(cls, key)
        end,
    })
end

---@diagnostic disable-next-line: param-type-mismatch
M = make_functional_index(Color, M)

return M
