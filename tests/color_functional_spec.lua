assert = require("luassert")
local Color = require("colorful.color")
local F = require("colorful.color.functional")

describe("Map", function()
    ---@type Color
    local base
    before_each(function()
        base = Color(0.2, 0.35, 0.85)
    end)

    it("should return `nil` with `nil` input", function()
        local result = Color.map(nil, F.lighten(0))
        assert.is_nil(result)
    end)

    it("should apply the closure with valid inputs", function()
        local function ident(x)
            return x
        end
        local result = Color.map(base, ident, ident, ident)
        assert.equal(base, result)
    end)

    it("should apply `Color:rotate` to a color", function()
        local expected = base:copy():rotate(0.9)
        local result = Color.map(base, F.rotate(0.9))
        assert.equal(expected, result)
    end)

    it("should apply `Color:saturate` to a color", function()
        local expected = base:copy():saturate(-0.02)
        local result = Color.map(base, F.saturate(-0.02))
        assert.equal(expected, result)
    end)

    it("should apply `Color:lighten` to a color", function()
        local expected = base:copy():lighten(0.65)
        local result = Color.map(base, F.lighten(0.65))
        assert.equal(expected, result)
    end)

    -- TODO: add more tests
end)
