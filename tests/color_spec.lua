assert = require("luassert")
local u = require("colorful.utils")

describe("RGBColor", function()
    local RGBColor = require("colorful.color").RGBColor

    ---@type RGBColor
    local pink
    before_each(function()
        pink = RGBColor(1, 0.4745098039215686, 0.7764705882352941) -- #ff79c5
    end)

    it("should parse a valid hex color string - `#RRGGBB`", function()
        local color = RGBColor:parse("#123abc")
        local r = u.round(color.r * 255)
        local g = u.round(color.g * 255)
        local b = u.round(color.b * 255)
        assert.equal(r, 18)
        assert.equal(g, 58)
        assert.equal(b, 188)
    end)

    it("should parse a short hex color string - `#RGB`", function()
        local color = RGBColor:parse("#123abc")
        local r = u.round(color.r * 255)
        local g = u.round(color.g * 255)
        local b = u.round(color.b * 255)
        assert.equal(r, 18)
        assert.equal(g, 58)
        assert.equal(b, 188)
    end)

    it("should return tostring with the form `#RRGGBB`", function()
        assert.equal(tostring(pink), "#ff79c6")
    end)

    it("should convert to HSL", function()
        local hsl = pink:hsl()
        assert.are_not_equal(pink, hsl)

        local h = u.round(hsl.h * 360) % 360
        local s = u.round(hsl.s * 100)
        local l = u.round(hsl.l * 100)
        assert.equal(h, 326)
        assert.equal(s, 100)
        assert.equal(l, 74)
    end)

    it("should unpack compoenents", function()
        local r, g, b = RGBColor(0.1, 0.2, 0.3):unpack()
        assert.equal(r, 0.1)
        assert.equal(g, 0.2)
        assert.equal(b, 0.3)
    end)
end)

describe("HSLColor", function()
    local HSLColor = require("colorful.color").HSLColor

    ---@type HSLColor
    local pink
    before_each(function()
        pink = HSLColor(326 / 360, 1, 0.74) -- #ff79c5
    end)

    it("should parse a valid hsl string - `hsl(X, Y%, Z%)`", function()
        local color = HSLColor:parse("hsl(326, 100%, 74%)")
        local h = u.round(color.h * 360) % 360
        assert.equal(h, 326)
        assert.equal(color.s, 1)
        assert.equal(color.l, 0.74)
    end)

    it("should parse a simple css hsl string - hsl(Xdeg Y% Z%)", function()
        local color = HSLColor:parse("hsl(326deg 100% 74%)")
        local h = u.round(color.h * 360) % 360
        assert.equal(h, 326)
        assert.equal(color.s, 1)
        assert.equal(color.l, 0.74)
    end)

    it("should return tostring with the form `hsl(H, S%, L%)`", function()
        assert.equal(tostring(pink), "hsl(326, 100%, 74%)")
    end)

    it("should unpack compoenents", function()
        local h, s, l = HSLColor(0.1, 0.2, 0.3):unpack()
        assert.equal(h, 0.1)
        assert.equal(s, 0.2)
        assert.equal(l, 0.3)
    end)
end)
