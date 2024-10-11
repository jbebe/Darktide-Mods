---@module 'lovemenot/src/types/types'

local WwiseGameSyncSettings = require 'scripts/settings/wwise_game_sync/wwise_game_sync_settings'

---@param controller LovesMeNot
local function init(controller)
    local ratingsViewName = 'ratings_view'

    function controller:registerRatingsView()
        self.dmf:add_require_path('lovesmenot/src/views/ratings-view/ratings_view')
        self.dmf:add_require_path('lovesmenot/src/views/ratings-view/ratings_view_definitions')
        self.dmf:add_require_path('lovesmenot/src/views/ratings-view/ratings_view_settings')
        self.dmf:register_view({
            view_name = ratingsViewName,
            display_name = 'lovesmenot_ratingsview_title',
            view_settings = {
                init_view_function = function(ingame_ui_context)
                    return true
                end,
                class = 'RatingsView',
                disable_game_world = false,
                state_bound = true,
                path = 'lovesmenot/src/views/ratings-view/ratings_view',
                game_world_blur = 1.1,
                load_always = true,
                enter_sound_events = {
                    'wwise/events/ui/play_ui_enter_short'
                },
                exit_sound_events = {
                    'wwise/events/ui/play_ui_back_short'
                },
                wwise_states = {
                    options = WwiseGameSyncSettings.state_groups.options.ingame_menu,
                },
            },
            view_transitions = {},
            view_options = {}
        })
    end

    -- Check whether something might block the full screen dashboard
    local function restrictedViewsCheck()
        local restrictedViews = {
            'title_view',
            'loading_view',
            'inventory_view',
        }
        for _, viewName in ipairs(restrictedViews) do
            if Managers.ui:view_active(viewName) then
                return false
            end
        end
        return true
    end

    function controller.dmf.openRatings()
        if not controller.initialized then
            controller:log('info', 'Failed to open ratings because mod is not initialized', 'controller:dmf:openRatings')
            return
        end
        if Managers.ui:view_instance(ratingsViewName) then
            Managers.ui:close_view(ratingsViewName)
        elseif restrictedViewsCheck() and not Managers.ui:chat_using_input() then
            ---@type RatingsViewContext
            local context = {
                controller = controller,
                definitions = modRequire 'lovesmenot/src/views/ratings-view/ratings_view_definitions' (controller),
                blueprints = modRequire 'lovesmenot/src/views/ratings-view/ratings_view_blueprints',
                settings = modRequire 'lovesmenot/src/views/ratings-view/ratings_view_settings',
            }
            Managers.ui:open_view(ratingsViewName, nil, nil, nil, nil, context)
        end
    end
end

return init
