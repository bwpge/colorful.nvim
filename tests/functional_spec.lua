assert = require("luassert")
local Color = require("colorful.color")
local F = require("colorful.functional")

describe("Map", function()
    ---@type Color
    local base
    before_each(function()
        base = Color(0.2, 0.35, 0.85)
    end)

    it("should return `nil` with `nil` input", function()
        local result = F.map(nil, tostring)
        assert.is_nil(result)
    end)

    it("should apply the closure with valid input", function()
        local result = F.map(10, tostring)
        assert.equal("10", result)
    end)

    it("should apply `Color:rotate` to a color", function()
        local expected = base:copy():rotate(0.9)
        local result = F.map(base, F.rotate(0.9))
        assert.equal(expected, result)
    end)

    it("should apply `Color:saturate` to a color", function()
        local expected = base:copy():saturate(-0.02)
        local result = F.map(base, F.saturate(-0.02))
        assert.equal(expected, result)
    end)

    it("should apply `Color:lighten` to a color", function()
        local expected = base:copy():lighten(0.65)
        local result = F.map(base, F.lighten(0.65))
        assert.equal(expected, result)
    end)
end)
