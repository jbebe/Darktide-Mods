local constants = modRequire 'lovesmenot/src/constants'
local VERSION, RATINGS, COLORS, SYMBOLS =
    constants.VERSION, constants.RATINGS, constants.COLORS, constants.SYMBOLS
local gameUtils = modRequire 'lovesmenot/src/utils/game'
local styleUtils = modRequire 'lovesmenot/src/utils/style'

---@param controller LovesMeNot
local function init(controller)
    function controller:updateRating(teammate)
        if self.rating == nil then
            self.rating = {
                version = VERSION,
                accounts = {}
            }
        end

        local message
        local isError = false
        local copy = table.clone(teammate)
        if not self.rating.accounts[teammate.accountId] then
            -- account has not been rated yet, create object
            copy.rating = RATINGS.AVOID
            self.rating.accounts[teammate.accountId] = copy
            message = controller.dmf:localize('lovesmenot_ingame_notification_set', teammate.characterName,
                controller.dmf:localize('lovesmenot_ingame_rating_avoid'))
            message = styleUtils.colorize(COLORS.ORANGE, SYMBOLS.FLAME) .. ' ' .. message
            isError = true
        elseif self.rating.accounts[teammate.accountId].rating == RATINGS.AVOID then
            -- account hasn been rated, cycle to prefer
            copy.rating = RATINGS.PREFER
            self.rating.accounts[teammate.accountId] = copy
            message = controller.dmf:localize('lovesmenot_ingame_notification_set', teammate.characterName,
                controller.dmf:localize('lovesmenot_ingame_rating_prefer'))
            message = styleUtils.colorize(COLORS.GREEN, SYMBOLS.WREATH) .. ' ' .. message
        else
            -- account was rated, remove from table
            self.rating.accounts[teammate.accountId] = nil
            message = controller.dmf:localize('lovesmenot_ingame_notification_unset', teammate.characterName)
            message = styleUtils.colorize(COLORS.GREEN, SYMBOLS.CHECK) .. ' ' .. message
        end

        -- user feedback
        gameUtils.directNotification(message, isError)
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
            self:updateRating(selected)
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
