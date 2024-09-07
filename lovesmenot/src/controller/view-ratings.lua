local WwiseGameSyncSettings = require "scripts/settings/wwise_game_sync/wwise_game_sync_settings"

---@param controller LovesMeNot
local function init(controller)
    local ratingsViewName = "ratings_view"

    function controller:registerRatingsView()
        controller.dmf:add_global_localize_strings({
            loc_ratings_view_display_name = {
                en = "Ratings",
            }
        })

        controller.dmf:add_require_path("lovesmenot/src/views/ratings-view/ratings_view")
        controller.dmf:add_require_path("lovesmenot/src/views/ratings-view/ratings_view_definitions")
        controller.dmf:add_require_path("lovesmenot/src/views/ratings-view/ratings_view_settings")
        controller.dmf:register_view({
            view_name = ratingsViewName,
            display_name = "loc_ratings_view_display_name",
            view_settings = {
                init_view_function = function(ingame_ui_context)
                    return true
                end,
                class = "RatingsView",
                disable_game_world = false,
                state_bound = true,
                path = "lovesmenot/src/views/ratings-view/ratings_view",
                game_world_blur = 1.1,
                load_always = true,
                enter_sound_events = {
                    "wwise/events/ui/play_ui_enter_short"
                },
                exit_sound_events = {
                    "wwise/events/ui/play_ui_back_short"
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
            "title_view",
            "loading_view",
            "inventory_view",
        }
        for _, viewName in ipairs(restrictedViews) do
            if Managers.ui:view_active(viewName) then
                return false
            end
        end
        return true
    end

    function controller:openRatings()
        if not controller.initialized then
            controller.dmf:echo("Lovesmenot is not initialized")
            return
        end
        if Managers.ui:view_instance(ratingsViewName) then
            Managers.ui:close_view(ratingsViewName)
        elseif restrictedViewsCheck() and not Managers.ui:chat_using_input() then
            local context = {}
            Managers.ui:open_view(ratingsViewName, nil, nil, nil, nil, context)
        end
    end
end

return init
