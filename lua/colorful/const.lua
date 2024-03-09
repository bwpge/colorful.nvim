local M = {}

---Lookup table to emulate unions for indexing vector components.
M.VEC_COMPONENTS = {
    x = "x",
    y = "y",
    z = "z",
    r = "x",
    g = "y",
    b = "z",
    h = "x",
    s = "y",
    l = "z",
}

---Lookup table for indexing RGB components.
M.RGB_COMPONENTS = {
    r = "x",
    g = "y",
    b = "z",
}

---Lookup table for indexing HSL components.
M.HSL_COMPONENTS = {
    h = "x",
    s = "y",
    l = "z",
}

---Lookup table for highlight group color keys and their aliases.
M.HL_COLOR_KEYS = {
    fg = "fg",
    foreground = "fg",
    bg = "bg",
    background = "bg",
    sp = "sp",
    special = "sp",
}

return M
