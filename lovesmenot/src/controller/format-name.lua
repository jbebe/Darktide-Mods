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

    ---@param text string
    ---@param isCommunityRated boolean | nil
    local function cleanRating(text, isCommunityRated)
        local result = text
        for _, prefix in pairs(isCommunityRated and COMMUNITY_NAME_PREFIX or NAME_PREFIX) do
            if langUtils.startsWith(text, prefix) then
                result = text:sub(#prefix)
                break
            end
        end
        result = result:gsub('^ +', '')

        return result
    end

    function controller:formatPlayerName(originalText, uid, overrideLevel)
        local rating, isCommunityRated = self:getRating(uid, overrideLevel)
        if not rating then
            -- show default name without any prefixes
            local cleanedText = cleanRating(originalText, isCommunityRated)
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
            local textRaw = cleanRating(originalText, isCommunityRated)

            return ratingPrefix .. textRaw, true
        end
    end
end

return init
