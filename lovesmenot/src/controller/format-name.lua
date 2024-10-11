local constants = modRequire 'lovesmenot/src/constants'
local langUtils = modRequire 'lovesmenot/src/utils/language'
local styleUtils = modRequire 'lovesmenot/src/utils/style'

local RATINGS, COLORS, SYMBOLS =
    constants.RATINGS, constants.COLORS, constants.SYMBOLS

---@param controller LovesMeNot
local function init(controller)
    local NAME_PREFIX = {
        [RATINGS.NEGATIVE] = styleUtils.colorize(COLORS.ORANGE, SYMBOLS.FLAME) .. ' ',
        [RATINGS.POSITIVE] = styleUtils.colorize(COLORS.GREEN, SYMBOLS.WREATH) .. ' ',
    }
    local COMMUNITY_NAME_PREFIX = {
        [RATINGS.NEGATIVE] = SYMBOLS.WEB .. styleUtils.colorize(COLORS.ORANGE, SYMBOLS.FLAME) .. ' ',
        [RATINGS.POSITIVE] = SYMBOLS.WEB .. styleUtils.colorize(COLORS.GREEN, SYMBOLS.WREATH) .. ' ',
    }

    local function cleanRating(text)
        local result = text
        for _, prefix in pairs(NAME_PREFIX) do
            if langUtils.startsWith(text, prefix) then
                result = text:sub(#prefix)
                break
            end
        end

        -- strip icon from vanilla name: '{color}<unicode>{reset} <name>' -> '<name>'
        -- TODO: remove all smybols
        -- {#color(255,75,20)}{#reset()} Martack {#color(216,229,207,120)}[BOT]{#reset()} - 1 
        result = result
            :gsub('^' .. SYMBOLS.WEB, '')
            :gsub('^%b{}', '')
            :gsub('^' .. SYMBOLS.VETERAN, '')
            :gsub('^' .. SYMBOLS.ZEALOT, '')
            :gsub('^' .. SYMBOLS.PSYKER, '')
            :gsub('^' .. SYMBOLS.OGRYN, '')
            :gsub('^' .. SYMBOLS.TORSO, '')
            :gsub('^' .. SYMBOLS.FLAME, '')
            :gsub('^' .. SYMBOLS.WREATH, '')
            :gsub('^%b{}', '')
            :gsub('^ ', '')

        return result
    end

    function controller:formatPlayerName(originalText, uid)
        local rating, isCommunityRated = self:getRating(uid)
        if not rating then
            -- show default name without any prefixes
            local cleanedText = cleanRating(originalText)
            if originalText == cleanedText then
                -- default player name, unchanged
                return originalText, false
            end

            -- default player name, changed from rated
            return cleanedText, true
        end

        local ratingPrefix = isCommunityRated and COMMUNITY_NAME_PREFIX[rating] or NAME_PREFIX[rating]
        if langUtils.startsWith(originalText, ratingPrefix) then
            -- prefix already applied
            return originalText, false
        else
            -- prefix is different, replace it, mark it dirty
            local textRaw = cleanRating(originalText)

            return ratingPrefix .. textRaw, true
        end
    end
end

return init
