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
        local creationDate = languageUtils.os.date(constants.DATE_FORMAT) --[[ @as string ]]
        copy.creationDate = creationDate
        if not self.localRating.accounts[teammate.uid] then
            -- account has not been rated yet, create object
            copy.rating = RATINGS.NEGATIVE
            self.localRating.accounts[teammate.uid] = copy
            message = controller.dmf:localize(
                'lovesmenot_ingame_notification_set',
                teammate.characterName,
                controller.dmf:localize('lovesmenot_ingame_rating_negative')
            )
            message = styleUtils.colorize(COLORS.ORANGE, SYMBOLS.FLAME) .. ' ' .. message
            isError = true
        elseif self.localRating.accounts[teammate.uid].rating == RATINGS.NEGATIVE then
            -- account hasn been rated, cycle to positive
            copy.rating = RATINGS.POSITIVE
            self.localRating.accounts[teammate.uid] = copy
            message = controller.dmf:localize(
                'lovesmenot_ingame_notification_set',
                teammate.characterName,
                controller.dmf:localize('lovesmenot_ingame_rating_positive')
            )
            message = styleUtils.colorize(COLORS.GREEN, SYMBOLS.WREATH) .. ' ' .. message
        else
            -- account was rated, remove from table
            self.localRating.accounts[teammate.uid] = nil
            message = controller.dmf:localize('lovesmenot_ingame_notification_unset', teammate.characterName)
            message = styleUtils.colorize(COLORS.GREY, SYMBOLS.CHECK) .. ' ' .. message
        end

        -- user feedback
        gameUtils.directNotification(message, isError)
    end

    -- Remark: updateLocalRating and updateCommunityRating are decoupled because the logic is vastly different
    function controller:updateCommunityRating(teammate)
        if not self.accountCache then
            self:log('error', 'Account cache is not initialized', 'controller:updateCommunityRating')
            return false
        end
        local cache = self.accountCache[teammate.uid]
        if not cache then
            self:log('error', 'Player uid is not found in account cache', 'controller:updateCommunityRating')
            return false
        end

        local isCacheLoaded = cache.level ~= nil
        if not isCacheLoaded then
            self:log('error', 'Player level is not loaded yet', 'controller:updateCommunityRating')
            return false
        end

        local hash = cache.hash
        if not self.localRating or not self.localRating.accounts[teammate.uid] then
            -- account has not been rated yet, create object
            self.syncableRating[hash] = {
                level = cache.level,
                rating = RATINGS.NEGATIVE,
            }
        elseif self.localRating.accounts[teammate.uid].rating == RATINGS.NEGATIVE then
            -- account hasn been rated, cycle to positive
            self.syncableRating[hash] = {
                level = cache.level,
                rating = RATINGS.POSITIVE,
            }
        else
            -- account was rated, remove from table
            self.syncableRating[hash] = nil
        end

        return true
    end

    function controller:rateTeammate(teammateIndex)
        if not self.initialized or not self.isInMission then
            self:log('info', 'User tried to rate people outside of mission', 'controller:rateTeammate')
            return
        end

        local selected = self.teammates[teammateIndex]
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
