local constants = modRequire 'lovesmenot/src/constants'
local ViewElementPlayerSocialPopup = require
    'scripts/ui/view_elements/view_element_player_social_popup/view_element_player_social_popup'

---@param controller LovesMeNot
local function init(controller)
    ---@param menu_items any[]
    local function getRatingWidgetIndex(menu_items, label)
        for i, item in ipairs(menu_items) do
            if item.label == label then
                return i
            end
        end
    end

    controller.dmf:hook(ViewElementPlayerSocialPopup, '_set_player_info',
        ---@param player_info PlayerInfo
        function(next, self, parent, player_info, menu_items, num_menu_items, show_friend_code)
            ---@type PlayerProfile
            local playerProfile = player_info:profile()
            local labelContent = constants.SYMBOLS.WEB .. ' ' .. Localize('lovesmenot_inspectview_options_rate')
            if playerProfile ~= nil then
                -- If player profile is not available, we can't rate the player
                local ratingWidget = {
                    blueprint = 'button',
                    label = labelContent,
                    callback = function()
                        controller:forceToggleRatingSafe(player_info)
                    end
                }
                local index = getRatingWidgetIndex(menu_items, labelContent)
                if index ~= nil then
                    menu_items[index] = ratingWidget
                    num_menu_items = #menu_items
                else
                    table.insert(menu_items, ratingWidget)
                    num_menu_items = num_menu_items + 1
                end
            else
                controller:log(
                    'warning',
                    'Popup player has no profile data',
                    'ViewElementPlayerSocialPopup:set_player_info'
                )
            end

            next(self, parent, player_info, menu_items, num_menu_items, show_friend_code)
        end)
end

return init
