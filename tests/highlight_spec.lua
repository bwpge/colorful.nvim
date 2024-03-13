assert = require("luassert")

describe("Highlight", function()
    local Highlight = require("colorful.highlight")
    local ns_id = vim.api.nvim_create_namespace("colorful_tests")

    it("should create an empty highlight", function()
        local hl = Highlight()
        assert.is_table(hl)
        assert.is_true(#hl == 0)
    end)

    it("should create a highlight from name", function()
        local hl = Highlight("Normal")
        assert.is_table(hl)
    end)

    it("should set the highlight group values", function()
        local t = {
            fg = "#ff00ff",
            bg = "#00ffff",
            bold = true,
        }
        local hl = Highlight.new(t)
        assert.equal(t.fg, hl.fg:tostring())
        assert.equal(t.bg, hl.bg:tostring())
        assert.equal(t.bold, hl.bold)

        hl:set("SetHighlightTest", ns_id)
        local after = Highlight.from_group("SetHighlightTest", ns_id)
        assert.equal(t.fg, after.fg:tostring())
        assert.equal(t.bg, after.bg:tostring())
        assert.equal(t.bold, after.bold)
    end)
end)
