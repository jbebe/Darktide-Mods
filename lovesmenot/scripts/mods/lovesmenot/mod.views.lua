local mod = get_mod("lovesmenot")
local WwiseGameSyncSettings = require("scripts/settings/wwise_game_sync/wwise_game_sync_settings")
local PlayerCharacterOptionsView = require(
    "scripts/ui/views/player_character_options_view/player_character_options_view")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

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
    if not mod.initialized then
        mod:echo("Lovesmenot is not initialized")
        return
    end
    if Managers.ui:view_instance(ratingsViewName) then
        Managers.ui:close_view(ratingsViewName)
    elseif restrictedViewsCheck() and not Managers.ui:chat_using_input() then
        local context = {}
        Managers.ui:open_view(ratingsViewName, nil, nil, nil, nil, context)
    end
end

--
-- Inspect view alteration
--

function PlayerCharacterOptionsView._on_rate_pressed(self)
    mod:update_rating({
        accountId = self._account_id,
        name = self._player_info:profile().name,
    })
    mod:persistRating()
end

mod:hook(PlayerCharacterOptionsView, "_setup_buttons_interactions", function(func, self, ...)
    func(self, ...)

    local widgets_by_name = self._widgets_by_name
    widgets_by_name.rate_button.content.hotspot.pressed_callback = callback(self, "_on_rate_pressed")
    self._button_gamepad_navigation_list = {
        widgets_by_name.inspect_button,
        widgets_by_name.invite_button,
        widgets_by_name.close_button,
        widgets_by_name.rate_button,
    }
end)

mod:hook(PlayerCharacterOptionsView, "init", function(func, self, ...)
    func(self, ...)

    local sceneGraphs = self._definitions.scenegraph_definition
    sceneGraphs.rate_button = {
        horizontal_alignment = "left",
        parent = "player_panel",
        vertical_alignment = "bottom",
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

    mod:add_global_localize_strings({
        loc_ratings_character_options_rate = {
            en = "Toggle player rating"
        }
    })

    local widgets = self._definitions.widget_definitions
    widgets.rate_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button, "rate_button", {
        visible = true,
        original_text = Localize("loc_ratings_character_options_rate"),
    })
end)
