local DMF = get_mod("DMF")
local RegionLatency = require 'scripts/backend/region_latency'

local localization = modRequire 'lovesmenot/src/mod.localization'
local gameUtils = modRequire 'lovesmenot/src/utils/game'
local constants = modRequire 'lovesmenot/src/constants'

---@param controller LovesMeNot
local function init(controller)
    function controller:reinit()
        if self.initialized then
            return
        end

        self.localPlayer = Managers.player:local_player_safe(1)
        if self.localPlayer == nil then
            -- account not yet available, retry later
            return
        end

        self.initialized = true

        if self:isCommunity() then
            local accessToken = controller:getAccessToken()
            if accessToken ~= nil then
                self:downloadCommunityRating()
                self:loadLocalPlayerToCache()
            else
                gameUtils.directNotification('Access token is not set. Mod is temporarily disabled.', true)
                DMF.set_mod_state(controller.dmf, false, false)
                return
            end
        end
        self:loadLocalRating()
        self.isInMission = gameUtils.isInRealMission()
        self:registerRatingsView()
        RegionLatency:get_preferred_reef():next(function(data)
            controller.reef = data
        end)
        controller.dmf:add_global_localize_strings({
            lovesmenot_ratingsview_download_ratings = localization.lovesmenot_ratingsview_download_ratings,
            lovesmenot_ratingsview_download_ratings_notif = localization.lovesmenot_ratingsview_download_ratings_notif,
        })
    end

    ---@param initial_call boolean
    function controller.dmf.on_enabled(initial_call)
        -- init mod (again) on reload all mods
        controller:reinit()
    end

    function controller.dmf.on_setting_changed(settingId)
        local communityId = 'lovesmenot_settings_community'
        if settingId ~= communityId then
            return
        end

        -- globalize localizations (lol)
        controller.dmf:add_global_localize_strings({
            lovesmenot_community_create_token_title = localization.lovesmenot_community_create_token_title,
            lovesmenot_community_create_token_description = localization.lovesmenot_community_create_token_description,
            lovesmenot_community_create_token_step_1 = localization.lovesmenot_community_create_token_step_1,
            lovesmenot_community_create_token_url = localization.lovesmenot_community_create_token_url,
            lovesmenot_community_create_token_step_2 = localization.lovesmenot_community_create_token_step_2,
            lovesmenot_community_create_token_step_3 = localization.lovesmenot_community_create_token_step_3,
            lovesmenot_community_create_token_save = localization.lovesmenot_community_create_token_save,
            lovesmenot_ratingsview_delete_no = localization.lovesmenot_ratingsview_delete_no,
        })

        local isCommunity = controller.dmf:get(communityId)
        if isCommunity then
            local context = {
                title_text = 'lovesmenot_community_create_token_title',
                description_text = 'lovesmenot_community_create_token_description',
                options = {
                    {
                        margin_bottom = 10,
                        template_type = "text",
                        text = "lovesmenot_community_create_token_step_1",
                    },
                    {
                        margin_bottom = 10,
                        template_type = "terminal_button_small",
                        text = 'lovesmenot_community_create_token_url',
                        close_on_pressed = false,
                        callback = function()
                            Application.open_url_in_browser(constants.AUTH_URL)
                        end,
                    },
                    {
                        margin_bottom = 10,
                        template_type = "text",
                        text = "lovesmenot_community_create_token_step_2",
                    },
                    {
                        margin_bottom = -4,
                        max_length = 256,
                        template_type = "terminal_input_field",
                        width = 300,
                    },
                    {
                        margin_bottom = 10,
                        template_type = "text",
                        text = "lovesmenot_community_create_token_step_3",
                    },
                    {
                        margin_bottom = 10,
                        template_type = "terminal_button_small",
                        text = 'lovesmenot_community_create_token_save',
                        close_on_pressed = true,
                        callback = function(accessToken)
                            controller.dmf:set('lovesmenot_settings_community_access_token', accessToken, false)
                            gameUtils.directNotification('Access token successfully registered', false)
                            controller:reinit()
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
                            local view_name = "dmf_options_view"
                            Managers.ui:close_view(view_name)
                        end,
                    },
                },
            }
            Managers.event:trigger('event_show_ui_popup', context)
        else
            -- clean community input state
        end
    end

    -- Main event handling
    -- We catch global state changes to run functions at specific times,
    -- not neccessarily during playing a level.
    function controller.dmf.on_game_state_changed(status, state_name)
        if state_name == 'StateMainMenu' and status == 'enter' then
            -- Game loaded, user is at the character selector menu
            controller:reinit()
        elseif state_name == 'GameplayStateRun' and status == 'enter' then
            -- Mission started
            if not controller.initialized then
                return
            end
            -- Set if in real mission
            controller.isInMission = gameUtils.isInRealMission()
        elseif state_name == 'StateGameplay' and status == 'exit' then
            -- Mission ended
            if controller:canRate() then
                controller.isInMission = false
                controller.teammates = {}
                if controller:isCommunity() then
                    controller:uploadCommunityRating()
                end
                controller:persistLocalRating()
            end
        end
    end
end

return init
