local gameUtils = modRequire 'lovesmenot/src/utils/game'
local constants = modRequire 'lovesmenot/src/constants'

---@param controller LovesMeNot
local function init(controller)
    ---@param initial_call boolean
    function controller.dmf.on_enabled(initial_call)
        -- init logging before loading mod
        controller:initLogging()

        -- init mod (again) on reload all mods
        controller:log('info', 'Mod enabled', 'controller:dmf:on_enabled')
        controller:init()
    end

    ---@param exit_game boolean
    function controller.dmf.on_unload(exit_game)
        controller:log('info', 'Mod unloaded', 'controller:dmf:on_unload')
        controller.logFileHandle:close()
    end

    function controller.dmf.on_setting_changed(settingId)
        local communityId = 'lovesmenot_settings_community'
        if settingId ~= communityId then
            return
        end
        local isCommunity = controller.dmf:get(communityId)
        controller:log(
            'info',
            ('Mod settings %s changed to %s'):format(communityId, isCommunity),
            'controller:dmf:on_setting_changed'
        )
        local hasAccessToken = controller:getAccessToken() ~= nil
        if isCommunity and not hasAccessToken then
            local context = {
                title_text = 'lovesmenot_community_create_token_title',
                description_text = 'lovesmenot_community_create_token_description',
                options = {
                    {
                        margin_bottom = 10,
                        template_type = 'text',
                        text = 'lovesmenot_community_create_token_step_1',
                    },
                    {
                        margin_bottom = 10,
                        template_type = 'terminal_button_small',
                        text = 'lovesmenot_community_create_token_url',
                        close_on_pressed = false,
                        callback = function()
                            controller:log(
                                'info',
                                'Authentication website opened',
                                'controller:dmf:on_setting_changed/UrlButton'
                            )
                            Application.open_url_in_browser(constants.AUTH_URL)
                        end,
                    },
                    {
                        margin_bottom = 10,
                        template_type = 'text',
                        text = 'lovesmenot_community_create_token_step_2',
                    },
                    {
                        margin_bottom = -4,
                        max_length = 256,
                        template_type = 'terminal_input_field',
                        width = 300,
                    },
                    {
                        margin_bottom = 10,
                        template_type = 'text',
                        text = 'lovesmenot_community_create_token_step_3',
                    },
                    {
                        margin_bottom = 10,
                        template_type = 'terminal_button_small',
                        text = 'lovesmenot_community_create_token_save',
                        close_on_pressed = true,
                        callback = function(accessToken)
                            controller.dmf:set('lovesmenot_settings_community_access_token', accessToken, false)
                            gameUtils.directNotification('Access token successfully registered', false)
                            controller:log(
                                'info',
                                'Access token registered',
                                'controller:dmf:on_setting_changed/SaveButton'
                            )
                            controller:init(true)
                        end,
                    },
                    {
                        template_type = 'terminal_button_small',
                        text = 'lovesmenot_ratingsview_delete_no',
                        close_on_pressed = true,
                        callback = function()
                            controller.dmf:set('lovesmenot_settings_community', false, false)
                            -- Reset visuals by exiting dmf ui
                            -- This way, community will be false visually too
                            local view_name = 'dmf_options_view'
                            Managers.ui:close_view(view_name)
                            controller:log(
                                'info',
                                'Community registration cancelled',
                                'controller:dmf:on_setting_changed/CancelButton'
                            )
                        end,
                    },
                },
            }
            Managers.event:trigger('event_show_ui_popup', context)
        else
            -- if we have an access token or we change to local mode,
            -- the best way to handle this is to restart the mod
            controller:init(true)
        end
    end

    -- Main event handling
    -- We catch global state changes to run functions at specific times,
    -- not neccessarily during playing a level.
    function controller.dmf.on_game_state_changed(status, state_name)
        if state_name == 'StateMainMenu' and status == 'enter' then
            -- Game loaded, user is at the character selector menu
            controller:init()
        elseif state_name == 'GameplayStateRun' and status == 'enter' then
            -- Mission started
            if not controller.initialized then
                controller:log(
                    'warning',
                    'Mod is not initialized during mission start state',
                    'controller:dmf:on_game_state_changed'
                )
                return
            end
            controller.isInMission = true
        elseif state_name == 'StateGameplay' and status == 'exit' then
            -- Mission ended
            controller:log(
                'info',
                'Mission has ended',
                'controller:dmf:on_game_state_changed'
            )
            if controller.initialized then
                controller.isInMission = false
                controller.teammates = {}
                if controller:isCommunity() then
                    controller:uploadCommunityRatingAsync()
                else
                    gameUtils.directNotification(
                        controller.dmf:localize('lovesmenot_ingame_local_persist_success')
                    )
                end
                controller:persistLocalRating()
            end
        end
    end
end

return init
