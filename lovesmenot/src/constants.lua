---@enum RATINGS
local RATINGS = {
    AVOID = "avoid",
    PREFER = "prefer",
}

local SYMBOLS = {
    CHECK = "\u{e001}",
    FLAME = "\u{e020}",
    WREATH = "\u{e041}",
    PLATFORM_STEAM = "\u{e06b}",
    PLATFORM_XBOX = "\u{e06c}",
    PLATFORM_PSN = "\u{e071}",
    PLATFORM_UNKNOWN = "\u{e06f}",
}

return {
    VERSION = 1,
    RATINGS = RATINGS,
    SYMBOLS = SYMBOLS,
    COLORS = {
        ORANGE = "255,75,20",
        GREEN = "133,237,0",
    },
    PLATFORMS = {
        steam = SYMBOLS.PLATFORM_STEAM,
        xbox = SYMBOLS.PLATFORM_XBOX,
        psn = SYMBOLS.PLATFORM_PSN,
        unknown = SYMBOLS.PLATFORM_UNKNOWN,
    }
}
