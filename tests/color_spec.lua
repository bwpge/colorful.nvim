assert = require("luassert")
local u = require("colorful.utils")
local Color = require("colorful.color")

describe("Color()", function()
    it("should create a default color with 0 arguments", function()
        local color = Color()
        assert.equal(color.r, 0)
        assert.equal(color.g, 0)
        assert.equal(color.b, 0)
    end)

    it("should create a parsed color with 1 argument", function()
        local expected = Color.new_rgb(1, 1, 1)
        local rgb1 = Color("#FFFFFF")
        local rgb2 = Color(16777215)
        local hsl = Color("hsl(0, 100%, 100%)")

        assert.equal(rgb1, expected)
        assert.equal(rgb2, expected)
        assert.equal(hsl, expected)
        assert.equal(rgb1.r, 1)
        assert.equal(rgb1.g, 1)
        assert.equal(rgb1.b, 1)
    end)

    it("should create a color from RGB components with 3 arguments", function()
        local color = Color.new_rgb(0.5, 1, 0.25)
        assert.equal(color.r, 0.5)
        assert.equal(color.g, 1)
        assert.equal(color.b, 0.25)
    end)
end)

describe("Color.parse()", function()
    it("should accept a valid hex string - `#RRGGBB`", function()
        local color = Color.parse("#123abc")
        local r = u.round(color.r * 255)
        local g = u.round(color.g * 255)
        local b = u.round(color.b * 255)
        assert.equal(r, 18)
        assert.equal(g, 58)
        assert.equal(b, 188)
    end)

    it("should accept a decimal representation", function()
        local color = Color.parse(16742853)
        local r = u.round(color.r * 255)
        local g = u.round(color.g * 255)
        local b = u.round(color.b * 255)
        assert.equal(r, 255)
        assert.equal(g, 121)
        assert.equal(b, 197)
    end)

    it("should accept a short hex string - `#RGB`", function()
        local color = Color.parse("#123abc")
        local r = u.round(color.r * 255)
        local g = u.round(color.g * 255)
        local b = u.round(color.b * 255)
        assert.equal(r, 18)
        assert.equal(g, 58)
        assert.equal(b, 188)
    end)

    it("should accept a valid hsl string - `hsl(X, Y%, Z%)`", function()
        local color = Color.parse("hsl(326, 100%, 74%)")
        local h = u.round(color.h * 360) % 360
        assert.equal(h, 326)
        assert.equal(color.s, 1)
        assert.equal(color.l, 0.74)
    end)

    it("should accept a css-style hsl string - `hsl(Xdeg Y% Z%)`", function()
        local color = Color.parse("hsl(326deg 100% 74%)")
        local h = u.round(color.h * 360) % 360
        assert.equal(h, 326)
        assert.equal(color.s, 1)
        assert.equal(color.l, 0.74)
    end)
end)

describe("Color:tostring()", function()
    ---@type Color
    local pink
    before_each(function()
        pink = Color("#ff79c5")
    end)

    it("should return an RGB string with the form `#RRGGBB`", function()
        local expected = "#ff79c5"
        assert.equal(pink:tostring(), expected)
        assert.equal(pink:tostring("rgb"), expected)
    end)

    it("should return an HSL string with the form `hsl(H, S%, L%)`", function()
        local expected = "hsl(326, 100%, 74%)"
        assert.equal(pink:tostring("hsl"), expected)
    end)
end)

describe("Color", function()
    it("should clamp assigned RGB values", function()
        local color = Color.new_rgb(0.95, 0.95, 0.95)
        color.r = color.r + 100
        color.g = color.g + 100
        color.b = color.b + 100

        assert.equal(color.r, 1)
        assert.equal(color.g, 1)
        assert.equal(color.b, 1)
    end)

    it("should rotate/clamp assigned HSL values", function()
        local color = Color.new_hsl(0, 0.95, 0.95)
        color.h = color.h + 100
        color.s = color.s + 100
        color.l = color.l + 100

        assert.equal(color.h, 0)
        assert.equal(color.s, 1)
        assert.equal(color.l, 1)
    end)

    it("should properly evaluate equality with tables", function()
        local Vec3 = require("colorful.vec3")
        local color = Color(0, 0, 0)
        local obj = { _rgb = Vec3(), _hsl = Vec3() }

        assert.are_not_equal(color, {})
        assert.are_not_equal(color, obj)
        assert.equal(color, Color("#000"))
    end)

    it("should unpack RGB components", function()
        local r, g, b = Color.new_rgb(1, 1, 0.5):unpack()
        assert.equal(r, 1)
        assert.equal(g, 1)
        assert.equal(b, 0.5)
    end)

    it("should unpack HSL components", function()
        local h, s, l = Color.new_hsl(0.5, 1, 0.75):unpack("hsl")
        assert.equal(h, 0.5)
        assert.equal(s, 1)
        assert.equal(l, 0.75)
    end)

    -- TODO: add tests for color operations (blend, rotate, etc.)
end)
