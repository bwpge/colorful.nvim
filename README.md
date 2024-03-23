# colorful.nvim

A Neovim plugin providing a robust API for manipulating colors and highlight groups.

*This plugin is still under construction, use at your own risk!*

## Overview

This plugin aims to provide object-oriented, ergonomic interfaces:

- Callable modules for intuitive constructors (e.g., `Color("#abc123")`, or `Highlight("Normal")`)
- Methods returning `self` for chaining (e.g., `thing:foo():bar():baz()`)
- Manipulate colors in RGB or HSL space
- Simple interface to modify highlight groups
- Mapping methods to reduce boilerplate while preserving possibly `nil` colors

## Example: Borderless Telescope

A common challenge with customizing themes is that each colorscheme requires its own bespoke adjustments. For example, if you want Telescope windows to use a slightly lighter or darker background color, you will need to make this adjustment in the setup of every theme plugin that you may use. As you find new "relative" adjustments to make, this quickly becomes unmanageable.

The following example creates a [borderless Telescope style used by NvChad](https://nvchad.com/docs/features/#telescope_nvim) that is applied to every theme, without the need to touch any other configuration.

Using `lazy.nvim`, create a `colorful.lua` [plugin spec](https://github.com/folke/lazy.nvim?tab=readme-ov-file#-plugin-spec):

```lua
local function make_hl_table()
    local F = require("colorful.color.functional")
    local Highlight = require("colorful.highlight")

    -- use "Normal" for our base color palette. this is generally a safe bet to
    -- creating a consistent look across most themes
    local hl = Highlight("Normal")

    -- think of these colors as "swatches" on a palette. we can build these out
    -- using HSL functions to make the new colors feel consistent.
    local fg = hl.fg
    local bg = hl:map_copy("bg", F.lighten(0.02))
    local bg_dark = hl:map_copy("bg", F.lighten(-0.045))
    local dim = hl:map_copy("bg", F.lighten(0.125))
    -- use multiple groups to find accent colors; functions are usually a bit
    -- more contrasted/colorful in most colorschemes. other good choices are
    -- Keyword, String, or Constant. This function will fallback to using the
    -- value set by the Normal group if no other color was found.
    local accent = Highlight.get_fg("@function", "Function")

    -- this table will be used by `colorful.setup` to apply highlights per colorscheme.
    -- the `*` key applies to every colorscheme. if needed, lua patterns can be used
    -- as keys to apply changes to a colorscheme name that matches (such as `mytheme*`
    -- for mytheme-soft, mytheme-darker, etc.).
    return {
        -- always applied, regardless of theme name
        ["*"] = {
            TelescopeNormal = { fg = fg, bg = bg_dark },
            TelescopePreviewBorder = { fg = bg_dark, bg = bg_dark },
            TelescopePreviewTitle = { fg = accent, reverse = true, bold = true },
            TelescopePromptBorder = { fg = bg, bg = bg },
            TelescopePromptCounter = { fg = dim },
            TelescopePromptNormal = { fg = fg, bg = bg },
            TelescopePromptPrefix = { fg = accent },
            TelescopePromptTitle = { fg = accent, reverse = true, bold = true },
            TelescopeResultsBorder = { fg = bg_dark, bg = bg_dark },
            TelescopeResultsTitle = { fg = bg_dark, bg = bg_dark },
        },
        -- highlights specific to dracula, like a different accent color
        ["dracula"] = {
            -- ...
        },
        -- highlights specific to any catppuccin variant
        ["catppuccin*"] = {
            -- ...
        },
    }
end

return {
    "bwpge/colorful.nvim",
    opts = {
        -- this option accepts a function and expects it to return a table like we built above.
        -- using a function allows the colors to be "refreshed" each time it is called.
        highlights = make_hl_table,
        -- creates a ColorScheme autocmd to apply these changes on each colorscheme change
        create_autocmd = true,
        -- since we (presumably) load the plugin after the first colorscheme change, we probably
        -- need to apply the changes manually the first time. if you have a different setup, you
        -- can disable this behavior with `false`.
        apply_on_setup = true,
    },
    -- not strictly required, but we can lazy load to defer some of the work required to set the
    -- highlights (e.g., copying colors, adjustments, conversions, etc.)
    event = "VeryLazy",
}
```
## Installation

Note that if a `highlights` function is not provided, this plugin does nothing when `setup` is called.

With [`lazy.nvim`](https://github.com/folke/lazy.nvim) as a plugin:


```lua
{
    "bwpge/colorful.nvim",
    opts = {
        -- see above example for how to create a highlights function
        highlights = function()
            -- ...
        end,
    },
    event = "VeryLazy",
}
```

Or as a library dependency:


```lua
{
    "foo/bar",
    -- no setup required
    dependencies = { "bwpge/colorful.nvim" },
}
```

## Recipes

This section is by no means complete, but showcases sample usage of the library API.

Create new colors from RGB adjustments:

```lua
local Color = require("colorful.color")
local red = Color("#eb4034")

-- add 0.25 to R, G, and B components
local light_red = red:copy():adjust_rgb(0.25, 0.25, 0.25)
assert(red != light_red) -- :copy() prevents modifying original color

-- note how red got clamped to 1:
assert(light_red.r == 1)

print(light_red) -- prints `#ff8074`
assert(purple:tostring() == "#ff8074")
assert(purple:tostring("hsl") == "hsl(5, 100%, 73%)")
```

Create new colors from HSL adjustments:

```lua
local Color = require("colorful.color")
local blue = Color("#00f") -- or "#0000ff", or Color(0, 0, 1)

-- rotate hue by 30°, desaturate by 25%, and lighten by 10%
local purple = blue:copy():adjust_hsl(1/12, -0.25, 0.1)
assert(blue != purple) -- :copy() prevents modifying original color

-- or, less efficient method chaining:
-- local purple = blue:copy()
--     :rotate(1/12)
--     :saturate(-0.25)
--     :lighten(0.1)
-- (not recommended since HSL changes trigger RGB updates on each method call)

print(purple) -- prints `#994ce6`
assert(purple:tostring() == "#994ce6")
assert(purple:tostring("hsl") == "hsl(270, 75%, 60%)")
```

Create a new linked highlight group:


```lua
local Highlight = require("colorful.highlight")

Highlight.new({link = "Normal"})
    :set("MyNewGroup") -- MyNewGroup is now linked to Normal

-- or, equivalent:
-- local hl = Highlight()
-- hl.link = "Normal"
-- hl:set("MyNewGroup")
```

Create new highlight groups based on existing ones with mappings:

```lua
local Highlight = require("colorful.highlight")
local F = require("colorful.color.functional")

local hl = Highlight("TelescopePromptNormal")

-- use map for possibly nil colors;
-- to modify only a copy, use `map_copy`
hl:map("fg", F.saturate(0.25))
hl:map("bg", F.lighten(-0.05))

-- or, equivalent:
-- if hl.fg then
--     hl.fg:saturate(0.25)
-- end
-- if hl.bg then
--     hl.bg:saturate(0.25)
-- end

-- create a new highlight group
hl:set("MyNewGroup")
```
