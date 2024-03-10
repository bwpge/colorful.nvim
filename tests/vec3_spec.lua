assert = require("luassert")

describe("Vec3", function()
    local Vec3 = require("colorful.vec3")

    it("should index with x-y-z, r-g-b, h-s-l", function()
        local vec = Vec3(1, 2, 3)
        assert.equal(vec.x, 1)
        assert.equal(vec.y, 2)
        assert.equal(vec.z, 3)
        assert.equal(vec.r, 1)
        assert.equal(vec.g, 2)
        assert.equal(vec.b, 3)
        assert.equal(vec.h, 1)
        assert.equal(vec.s, 2)
        assert.equal(vec.l, 3)
    end)

    it("should be equal to a new vector with the same components", function()
        local v1 = Vec3(-1, 3.14159, 3000)
        local v2 = Vec3(-1, 3.14159, 3000)

        ---@diagnostic disable-next-line: invisible
        assert.is_true(v1:__eq(v2))
        assert.is_true(v1 == v2)
    end)

    it("should negate with unary minus operator", function()
        local vec = Vec3(-1, 3.14159, 3000)
        assert.equal(-vec, Vec3(1, -3.14159, -3000))
    end)

    it("should add two vectors", function()
        local v1 = Vec3(1, 2, 3)
        local v2 = Vec3(-1, -2, -1000)
        assert.equal(v1 + v2, Vec3(0, 0, -997))
    end)

    it("should subtract two vectors", function()
        local v1 = Vec3(0, 0, 3)
        local v2 = Vec3(-1, -2, -1000)
        assert.equal(v1 - v2, Vec3(1, 2, 1003))
    end)

    it("should be multiplied by a scalar", function()
        local vec = Vec3(50, 25, -10)
        assert.equal(vec * 2, Vec3(100, 50, -20))
    end)

    it("should be divided by a scalar", function()
        local vec = Vec3(1001, 2005, 42)
        assert.equal(vec / 10, Vec3(100.1, 200.5, 4.2))
    end)

    it("should have tostring return `[x, y, z]` without trailing zeroes", function()
        local vec = Vec3(0, 1.000002, -42)
        assert.equal(tostring(vec), "[0, 1.000002, -42]")
    end)

    it("should compute the dot product", function()
        local v1 = Vec3(3, 0, 2)
        local v2 = Vec3(-1, 4, 2)
        assert.equal(v1:dot(v2), 1)
    end)

    it("should compute the cross product", function()
        local v1 = Vec3(3, 0, 2)
        local v2 = Vec3(-1, 4, 2)
        assert.equal(v1:cross(v2), Vec3(-8, -8, 12))
    end)
end)
