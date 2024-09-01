local mod = get_mod("lovesmenot")
local WwiseGameSyncSettings = require("scripts/settings/wwise_game_sync/wwise_game_sync_settings")

local function initMod()
    mod.initialized = true
    mod.localPlayer = Managers.player:local_player_safe(1)
    mod:loadRating()
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
            self:persistRating()
        end
    end
end

--
-- Ratings view
--

local ratingsViewName = "ratings_view"

function mod.registerRatingsView(self)
    self:add_global_localize_strings({
        loc_ratings_view_display_name = {
            en = "Ratings",
        }
    })

    self:add_require_path("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view")
    self:add_require_path("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_definitions")
    self:add_require_path("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_settings")
    self:register_view({
        view_name = ratingsViewName,
        display_name = "loc_ratings_view_display_name",
        view_settings = {
            init_view_function = function(ingame_ui_context)
                return true
            end,
            class = "RatingsView",
            disable_game_world = false,
            state_bound = true,
            path = "lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view",
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
    self:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view")
end

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

function mod.openRatings(self)
    if Managers.ui:view_instance(ratingsViewName) then
        Managers.ui:close_view(ratingsViewName)
    elseif restrictedViewsCheck() and not Managers.ui:chat_using_input() then
        local context = {}
        Managers.ui:open_view(ratingsViewName, nil, nil, nil, nil, context)
    end
end
