local constants = modRequire 'lovesmenot/src/constants'
local VERSION, RATINGS, COLORS, SYMBOLS =
    constants.VERSION, constants.RATINGS, constants.COLORS, constants.SYMBOLS
local gameUtils = modRequire 'lovesmenot/src/utils/game'
local languageUtils = modRequire 'lovesmenot/src/utils/language'
local styleUtils = modRequire 'lovesmenot/src/utils/style'

---@param controller LovesMeNot
local function init(controller)
    function controller:updateLocalRating(teammate)
        if self.localRating == nil then
            self.localRating = {
                version = VERSION,
                accounts = {}
            }
        end

        local message
        local isError = false
        ---@type RatingAccount
        local copy = table.clone(teammate)
        local creationDate = languageUtils.os.date(constants.DATE_FORMAT)
        ---@cast creationDate string
        copy.creationDate = creationDate
        if not self.localRating.accounts[teammate.accountId] then
            -- account has not been rated yet, create object
            copy.rating = RATINGS.NEGATIVE
            self.localRating.accounts[teammate.accountId] = copy
            message = controller.dmf:localize('lovesmenot_ingame_notification_set', teammate.characterName,
                controller.dmf:localize('lovesmenot_ingame_rating_negative'))
            message = styleUtils.colorize(COLORS.ORANGE, SYMBOLS.FLAME) .. ' ' .. message
            isError = true
        elseif self.localRating.accounts[teammate.accountId].rating == RATINGS.NEGATIVE then
            -- account hasn been rated, cycle to positive
            copy.rating = RATINGS.POSITIVE
            self.localRating.accounts[teammate.accountId] = copy
            message = controller.dmf:localize('lovesmenot_ingame_notification_set', teammate.characterName,
                controller.dmf:localize('lovesmenot_ingame_rating_positive'))
            message = styleUtils.colorize(COLORS.GREEN, SYMBOLS.WREATH) .. ' ' .. message
        else
            -- account was rated, remove from table
            self.localRating.accounts[teammate.accountId] = nil
            message = controller.dmf:localize('lovesmenot_ingame_notification_unset', teammate.characterName)
            message = styleUtils.colorize(COLORS.GREEN, SYMBOLS.CHECK) .. ' ' .. message
        end

        -- user feedback
        gameUtils.directNotification(message, isError)
    end

    function controller:updateCommunityRating(teammate)
        if not self.accountCache then
            return false
        end
        local cache = self.accountCache[teammate.accountId]
        if not cache then
            print('Account id is not found in account cache')
            return false
        end

        local isCacheLoaded = cache.level ~= nil
        if not isCacheLoaded then
            print('Cached account is not fully loaded')
            return false
        end

        if not self.localRating or not self.localRating.accounts[teammate.accountId] then
            -- account has not been rated yet, create object
            self.syncableRating[teammate.accountId] = {
                level = cache.level,
                idHash = cache.idHash,
                rating = RATINGS.NEGATIVE,
            }
        elseif self.localRating.accounts[teammate.accountId].rating == RATINGS.NEGATIVE then
            -- account hasn been rated, cycle to positive
            self.syncableRating[teammate.accountId] = {
                level = cache.level,
                idHash = cache.idHash,
                rating = RATINGS.POSITIVE,
            }
        else
            -- account was rated, remove from table
            self.syncableRating[teammate.accountId] = nil
        end

        return true
    end

    function controller:rateTeammate(teammateIndex)
        if not self:canRate() then
            return
        end

        local selected = nil
        if teammateIndex == 1 and #self.teammates > 0 then
            selected = self.teammates[teammateIndex]
        elseif teammateIndex == 2 and #self.teammates > 1 then
            selected = self.teammates[teammateIndex]
        elseif teammateIndex == 3 and #self.teammates > 2 then
            selected = self.teammates[teammateIndex]
        end

        if selected then
            if self:isCommunity() then
                self:updateCommunityRating(selected)
            end
            self:updateLocalRating(selected)
        end
    end

    function controller.dmf.lovesmenot_settings_hotkey_1_title()
        controller:rateTeammate(1)
    end

    function controller.dmf.lovesmenot_settings_hotkey_2_title()
        controller:rateTeammate(2)
    end

    function controller.dmf.lovesmenot_settings_hotkey_3_title()
        controller:rateTeammate(3)
    end
end

return init
