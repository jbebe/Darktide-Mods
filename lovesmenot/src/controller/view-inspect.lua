local PlayerCharacterOptionsView = require
    'scripts/ui/views/player_character_options_view/player_character_options_view'
local UIWidget = require 'scripts/managers/ui/ui_widget'
local ButtonPassTemplates = require 'scripts/ui/pass_templates/button_pass_templates'

---@param controller LovesMeNot
local function init(controller)
    function PlayerCharacterOptionsView:_on_rate_pressed()
        ---@type PlayerInfo
        local playerInfo = self._player_info
        local accountName = playerInfo._presence:account_name()
        local platform = playerInfo:platform()
        local playerProfile = playerInfo:profile()
        ---@type Teammate
        local teammate = {
            name = accountName,
            platform = platform,
            characterName = playerProfile.name,
            characterType = playerProfile.archetype.name,
            characterLevel = playerProfile.current_level,
            uid = controller:uid(platform, playerInfo:platform_user_id())
        }
        if controller:isCommunity() then
            if controller:updateCommunityRating(teammate) then
                controller:uploadCommunityRatingAsync():next(function()
                    -- only update local rating if remote succeeded
                    controller:updateLocalRating(teammate)
                    controller:persistLocalRating()
                end)
            end
        else
            controller:updateLocalRating(teammate)
            controller:persistLocalRating()
        end
    end

    controller.dmf:hook_safe(PlayerCharacterOptionsView, '_setup_buttons_interactions', function(self)
        local widgets_by_name = self._widgets_by_name
        widgets_by_name.rate_button.content.hotspot.pressed_callback = callback(self, '_on_rate_pressed')
        self._button_gamepad_navigation_list = {
            widgets_by_name.inspect_button,
            widgets_by_name.invite_button,
            widgets_by_name.close_button,
            widgets_by_name.rate_button,
        }
    end)

    controller.dmf:hook_safe(PlayerCharacterOptionsView, 'init', function(self)
        local sceneGraphs = self._definitions.scenegraph_definition
        sceneGraphs.rate_button = {
            horizontal_alignment = 'left',
            parent = 'player_panel',
            vertical_alignment = 'bottom',
            size = {
                380,
                40,
            },
            position = {
                60,
                0,
                13,
            },
        }
        local widgets = self._definitions.widget_definitions
        widgets.rate_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button, 'rate_button', {
            visible = true,
            original_text = Localize('lovesmenot_inspectview_options_rate'),
        })
    end)
end

return init
