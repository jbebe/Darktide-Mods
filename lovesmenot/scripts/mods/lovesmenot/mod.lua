local mod = get_mod("lovesmenot")
local Missions = require("scripts/settings/mission/mission_templates")
local HumanPlayer = require("scripts/managers/player/human_player")
local utils = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/utils")

--
-- Constants
--

mod.VERSION = 1

local RATING = {
    AVOID = "avoid"
}

local SYMBOLS = {
    SKULL = "\u{e01e}",
    CHECK = "\u{e001}"
}

--
-- Properties
--

-- Cached local player instance
---@class HumanPlayer
mod.localPlayer = mod.localPlayer or nil

-- Whether the mod is loaded / ready
mod.initialized = mod.initialized or false

-- Rating object that stores ratings for players
-- (State in memory that is parsed from and saved to lovesmenot.json)
mod.rating = mod.rating or nil

-- Path to the persisted rating object
-- Versioned and extensible for future uses
mod.ratingPath = mod.ratingPath or utils.os.getenv('APPDATA') .. "\\Fatshark\\Darktide\\lovesmenot.json"

-- Temporary table that stores the current teammates.
-- Always updated to the latest one, so we can't rate a player that has left the game
mod.teammates = mod.teammates or {}

-- Whether we are in a mission.
-- (We are in a mission if a level is loaded and it is not of 'hub' type)
mod.isInMission = mod.isInMission or false

--
-- Getters
--

function mod.canRate(self)
    return self.initialized and self.isInMission
end

function mod._isInMission()
    if Managers.state.mission then
        local mission_name = Managers.state.mission:mission_name()
        if mission_name then
            local mission_settings = Missions[mission_name]
            if mission_settings then
                return not mission_settings.is_hub
            end
        end
    end

    return false
end

--
-- Init
--

mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/persistence")
mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/mod.hooks")
mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/mod.views")
mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/mod.commands")

function mod.formatPlayerName(self, originalName, accountId)
    if not self.rating then
        return originalName
    end

    local accData = self.rating.accounts[accountId]
    if not accData then
        return originalName
    end

    -- clean originalName (color, etc.)
    if accData.rating == RATING.AVOID then
        return "{#color(255,20,20)}" .. SYMBOLS.SKULL .. "{#reset()} " .. originalName
    end

    error('Unsupported rating type:' .. tostring(accData.rating))
end

--
-- Hooks
--

-- Player joins the lobby
-- Remarks: here we don't have to worry about bots because they join after the game has started
-- TODO: _assign_player_to_slot() maybe?
mod:hook_safe(CLASS.LobbyView, "_sync_player", function(self, unique_id, player)
    if not mod.initialized then return end

    local spawnSlots = self._spawn_slots
    local slotId = self:_player_slot_id(unique_id)
    local slot = spawnSlots[slotId]
    local content = slot.panel_widget.content

    content.character_name = mod:formatPlayerName(player:profile().name, player._account_id)
end)

-- Player joins midgame
-- TODO: this is just for debugging. move new player update to a less frequent function to avoid performance hit ()
--       or we can keep this one but don't set widget dirty to true if character name is already highlighted
mod:hook_safe(CLASS.HudElementTeamPanelHandler, "update",
    function(self, dt, t, ui_renderer, render_settings, input_service)
        if not mod.initialized then return end

        local remotePlayers = {}
        for _, data in ipairs(self._player_panels_array) do
            local player = data.player
            local accountId = player._telemetry_subject.account_id
            if accountId ~= mod.localPlayer._account_id then
                local characterName = player:profile().name
                table.insert(remotePlayers, {
                    accountId = accountId,
                    name = characterName
                })

                local panel = data.panel
                local widget = panel._widgets_by_name.player_name
                local content = widget.content

                -- change name
                content.text = mod:formatPlayerName(characterName, accountId)
                widget.dirty = true

                -- expand name container
                local container_size = widget.style.text.size
                if container_size then
                    container_size[1] = 500
                end
            end
        end

        mod.teammates = remotePlayers
    end)

-- player name above their head
local _get_markers_by_id = function()
    local ui_manager = Managers.ui
    local hud = ui_manager:get_hud()
    local world_markers = hud and hud:element("HudElementWorldMarkers")
    local markers_by_id = world_markers and world_markers._markers_by_id

    return markers_by_id
end
mod:hook_safe(CLASS.HudElementNameplates, "update", function(self)
    if not mod.initialized then return end

    local nameplates = self._nameplate_units
    local markers_by_id = _get_markers_by_id()

    for _, data in pairs(nameplates) do
        local id = data.marker_id
        local marker = markers_by_id[id]

        if marker then
            local player = marker.data
            local player_deleted = player.__deleted

            if not player_deleted then
                local content = marker.widget.content

                content.header_text = mod:formatPlayerName(player:profile().name, player._telemetry_subject.account_id)
                marker.tl_modified = true
            end
        end
    end
end)

-- game end screen
mod:hook_safe(CLASS.EndView, "_set_character_names", function(self)
    if not mod.initialized then return end

    local spawn_slots = self._spawn_slots

    if spawn_slots then
        for _, slot in ipairs(spawn_slots) do
            local widget = slot.widget

            if widget then
                local content = widget.content
                local account_id = slot.account_id

                if account_id ~= mod.localPlayer._account_id then
                    local player_info = slot.player_info
                    content.character_name = mod:formatPlayerName(player_info:profile().name, account_id)
                end
            end
        end
    end
end)

--
-- Hotkeys
--

function mod.update_rating(self, teammate)
    if self.rating == nil then
        self.rating = {
            version = mod.VERSION,
            accounts = {}
        }
    end

    local message
    if not self.rating.accounts[teammate.accountId] then
        -- account has not been rated yet, create object
        self.rating.accounts[teammate.accountId] = {
            rating = RATING.AVOID
        }
        message = mod:localize("rate_notification_text_set", teammate.name, mod:localize("rating_value_avoid"))
        message = "{#color(255,20,20)}" .. SYMBOLS.SKULL .. "{#reset()} " .. message
    else
        -- account was rated, remove from table
        self.rating.accounts[teammate.accountId] = nil
        message = mod:localize("rate_notification_text_unset", teammate.name)
        message = SYMBOLS.CHECK .. " " .. message
    end

    -- user feedback
    utils.direct_notification(message)

    -- update team panel to show changes
end

function mod.rate_teammate(self, teammateIndex)
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
        self:update_rating(selected)
    end
end

function mod.rate_teammate_1()
    mod:rate_teammate(1)
end

function mod.rate_teammate_2()
    mod:rate_teammate(2)
end

function mod.rate_teammate_3()
    mod:rate_teammate(3)
end

--
-- Register views
--

mod:registerRatingsView()

--
-- Type Hints
--

local __rating = {
    version = mod.VERSION,
    accounts = {
        ["3cc1cf49-8b7a-4fe7-bc03-7c65ad899962"] = {
            rating = RATING.AVOID
        }
    }
}
local __teammates = {
    {
        accountId = "3cc1cf49-8b7a-4fe7-bc03-7c65ad899962",
        name = "xXxD3sTr0yeRxXx"
    }
}
