local M = {}

---Transforms the input value with a function if it is not `nil`.
---@generic T
---@generic U
---@param val? T The input value
---@param fn fun(t: T): U? The mapping function
---@return U? _ The value returned by mapping function or `nil`
function M.map(val, fn)
    if val then
        return fn(val)
    end
    return nil
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:rotate(...)`.
---@param amount number
---@return fun(c: Color): Color
function M.rotate(amount)
    return function(c)
        return c:rotate(amount)
    end
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:saturate(...)`.
---@param amount number
---@return fun(c: Color): Color
function M.saturate(amount)
    return function(c)
        return c:saturate(amount)
    end
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:lighten(...)`.
---@param amount number
---@return fun(c: Color): Color
function M.lighten(amount)
    return function(c)
        return c:lighten(amount)
    end
end

return M
