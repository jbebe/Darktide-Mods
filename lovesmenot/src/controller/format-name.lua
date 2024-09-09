local constants = modRequire 'lovesmenot/src/constants'
local langUtils = modRequire 'lovesmenot/src/utils/language'
local styleUtils = modRequire 'lovesmenot/src/utils/style'

local RATINGS, COLORS, SYMBOLS =
    constants.RATINGS, constants.COLORS, constants.SYMBOLS

---@param controller LovesMeNot
local function init(controller)
    local NAME_PREFIX = {
        [RATINGS.AVOID] = styleUtils.colorize(COLORS.ORANGE, SYMBOLS.FLAME) .. ' ',
        [RATINGS.PREFER] = styleUtils.colorize(COLORS.GREEN, SYMBOLS.WREATH) .. ' ',
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
        result = result
            :gsub('^%b{}', '')
            :gsub('^' .. SYMBOLS.VETERAN, '')
            :gsub('^' .. SYMBOLS.ZEALOT, '')
            :gsub('^' .. SYMBOLS.PSYKER, '')
            :gsub('^' .. SYMBOLS.OGRYN, '')
            :gsub('^' .. SYMBOLS.TORSO, '')
            :gsub('^%b{}', '')
            :gsub('^ ', '')

        return result
    end

    function controller:formatPlayerName(oldText, accountId)
        if not self.rating then
            -- rating is not available, skip
            return oldText, false
        end

        local accData = self.rating.accounts[accountId]
        if not accData then
            local textRaw = cleanRating(oldText)
            if oldText == textRaw then
                -- default player name, unchanged
                return oldText, false
            end

            -- default player name, changed from rated
            return textRaw, true
        end

        local rating = accData.rating
        local ratingPrefix = NAME_PREFIX[rating]
        if langUtils.startsWith(oldText, ratingPrefix) then
            -- prefix already applied
            return oldText, false
        else
            -- prefix is different, replace it, mark it dirty
            local textRaw = cleanRating(oldText)

            return ratingPrefix .. textRaw, true
        end
    end
end

return init
