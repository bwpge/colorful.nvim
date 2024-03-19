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
---`Color:adjust_rgb(...)`.
---@param r number
---@param g number
---@param b number
---@return Color.MapFn
function M.adjust_rgb(r, g, b)
    return function(c)
        return c:adjust_rgb(r, g, b)
    end
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:adjust_hsl(...)`.
---@param h number
---@param s number
---@param l number
---@return Color.MapFn
function M.adjust_hsl(h, s, l)
    return function(c)
        return c:adjust_hsl(h, s, l)
    end
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:rotate(...)`.
---@param amount number
---@return Color.MapFn
function M.rotate(amount)
    return function(c)
        return c:rotate(amount)
    end
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:saturate(...)`.
---@param amount number
---@return Color.MapFn
function M.saturate(amount)
    return function(c)
        return c:saturate(amount)
    end
end

---Returns a closure (function) that takes a single `Color` input and returns the result of
---`Color:lighten(...)`.
---@param amount number
---@return Color.MapFn
function M.lighten(amount)
    return function(c)
        return c:lighten(amount)
    end
end

return M
