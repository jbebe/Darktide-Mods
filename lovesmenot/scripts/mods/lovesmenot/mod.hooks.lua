local mod = get_mod("lovesmenot")

local function initMod()
    mod.initialized = true
    mod.localPlayer = Managers.player:local_player_safe(1)
    mod:load_rating()
    mod.isInMission = mod:_isInMission()
end

mod.update = function(dt)
    if mod.initialized then
        return
    end

    -- update() is called on every game tick.
    -- We only call initMod if mod is not initialized.
    -- This function might hang the main thread as it loads files from the FS
    -- but it happens during the operator selection menu only.
    initMod()
end

-- Main event handling
-- We catch global state changes to run functions at specific times,
-- not neccessarily during playing a level.
mod.on_game_state_changed = function(self, status, state_name)
    if state_name == "StateMainMenu" and status == "enter" then
        -- Game loaded, user is at the character selector menu
        initMod()
    elseif state_name == "GameplayStateRun" and status == "enter" then
        -- Mission started
        if not mod.initialized then
            return
        end

        mod.isInMission = self:_isInMission()
    elseif state_name == "StateGameplay" and status == "exit" then
        -- Mission ended
        if mod.initialized and mod.isInMission then
            mod.isInMission = false
            mod.teammates = nil
            self:persist_rating()
        end
    end
end

mod:add_global_localize_strings({
    loc_ratings_view_display_name = {
        en = "Ratings",
    }
})

mod:add_require_path("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings-view")
mod:add_require_path("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings-view-definitions")
mod:add_require_path("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings-view-settings")
mod:register_view({
    view_name = "ratings_view",
    view_settings = {
        init_view_function = function(ingame_ui_context)
            return true
        end,
        class = "RatingsView",
        disable_game_world = false,
        display_name = "loc_ratings_view_display_name",
        game_world_blur = 1.1,
        load_always = true,
        load_in_hub = true,
        package = "packages/ui/views/options_view/options_view",
        path = "lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings-view",
        state_bound = true,
        enter_sound_events = {
            "wwise/events/ui/play_ui_enter_short"
        },
        exit_sound_events = {
            "wwise/events/ui/play_ui_back_short"
        },
        wwise_states = {
            options = "ingame_menu"
        },
    },
    view_transitions = {},
    view_options = {
        close_all = true,
        close_previous = true,
        close_transition_time = nil,
        transition_time = nil
    }
})
