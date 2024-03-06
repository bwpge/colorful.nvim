local M = {}

---Clamps a number between a minimum and maximum value.
---@param value number
---@param min number
---@param max number
---@return number
function M.clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

---Rounds a number to the nearest integer.
---@param value number
---@return integer
function M.round(value)
    return math.floor(value + 0.5)
end

---Returns whether or not a number is in a given range.
---@param value number
---@param min number
---@param max number
---@return boolean
function M.in_range(value, min, max)
    return value >= min and value <= max
end

return M
