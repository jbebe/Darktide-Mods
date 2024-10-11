---@enum RATINGS
local RATINGS = {
    NEGATIVE = 'negative',
    POSITIVE = 'positive',
}

local SYMBOLS = {
    CHECK = '\u{e001}',
    TORSO = '\u{e005}',
    FLAME = '\u{e020}',
    WREATH = '\u{e041}',
    WEB = '\u{e06f}',
    VETERAN = '\u{e01a}',
    ZEALOT = '\u{e01b}',
    PSYKER = '\u{e01c}',
    OGRYN = '\u{e01d}',
    PLATFORM_STEAM = '\u{e06b}',
    PLATFORM_XBOX = '\u{e06c}',
    PLATFORM_PSN = '\u{e071}',
    PLATFORM_UNKNOWN = '\u{e06f}',
}

local version = 1

return {
    VERSION = version,
    API_PREFIX = 'https://localhost:53531/' .. version,
    AUTH_URL = 'http://localhost:5173',
    RATINGS = RATINGS,
    SYMBOLS = SYMBOLS,
    COLORS = {
        ORANGE = '255,75,20',
        GREEN = '133,237,0',
        GREY = '133,133,133',
    },
    PLATFORMS = {
        steam = SYMBOLS.PLATFORM_STEAM,
        xbox = SYMBOLS.PLATFORM_XBOX,
        psn = SYMBOLS.PLATFORM_PSN,
        unknown = SYMBOLS.PLATFORM_UNKNOWN,
    },
    DATE_FORMAT = '!%Y-%m-%d %H:%M:%S', -- UTC date
    NOTIFICATION_DELAY_LONG = 5,
}
