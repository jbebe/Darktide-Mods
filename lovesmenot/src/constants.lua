---@enum RATINGS
local RATINGS = {
    AVOID = "avoid",
    PREFER = "prefer",
}

return {
    VERSION = 1,
    RATINGS = RATINGS,
    SYMBOLS = {
        CHECK = "\u{e001}",
        FLAME = "\u{e020}",
        WREATH = "\u{e041}",
    },
    COLORS = {
        ORANGE = "255,75,20",
        GREEN = "133,237,0",
    }
}
