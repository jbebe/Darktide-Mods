local mod = get_mod("lovesmenot")
local DMF = get_mod("DMF")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local Missions = require("scripts/settings/mission/mission_templates")
local HudLoader = require("scripts/loading/loaders/hud_loader")
local json = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/json")

local function traceback()
    local level = 1
    while true do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then -- is a C function?
            print(level, "C function")
        else                     -- a Lua function
            print(string.format("[%s]:%d",
                info.short_src, info.currentline))
        end
        level = level + 1
    end
end

local _io = DMF:persistent_table("_io")
_io.initialized = _io.initialized or false
if not _io.initialized then _io = DMF.deepcopy(Mods.lua.io) end

local _os = DMF:persistent_table("_os")
_os.initialized = _os.initialized or false
if not _os.initialized then _os = DMF.deepcopy(Mods.lua.os) end

-- constants
local RATING = {
    AVOID = "avoid"
}
local CURRENT_VERSION = 1
local SYMBOLS = {
    SKULL = "\u{e01e}",
    CHECK = "\u{e001}"
}

-- type hints
local __rating = {
    version = CURRENT_VERSION,
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

-- mod properties

---@class HumanPlayer (scripts/managers/player/human_player)
mod.localPlayer = nil
mod.initialized = false
mod.rating = nil
mod.ratingPath = _os.getenv('APPDATA') .. "\\Fatshark\\Darktide\\lovesmenot.json"

---@type table
mod.teammates = nil
mod.isInMission = false

local function direct_notification(message, isAlert)
    if Managers.event then
        Managers.event:trigger(
            "event_add_notification_message",
            "alert",
            { text = message } or "",
            nil,
            UISoundEvents.default_click
        )
    end
end

local function load_rating()
    local file = _io.open(mod.ratingPath, "r")
    if file ~= nil then
        -- file exists
        local rawContent = file:read("*all")
        file:close()
        -- ignore version, no migration needed yet
        mod.rating = json.decode(rawContent)
    else
        -- file does not exist
    end
end

-- save db to file
local function persist_rating()
    if not mod.rating then return end

    local jsonData = json.encode(mod.rating)
    local file = assert(_io.open(mod.ratingPath, "w"))
    file:write(jsonData)
    file:close()
end

local function initMod()
    mod.initialized = true
    mod.localPlayer = Managers.player:local_player_safe(1)
    load_rating()

    if Managers.state.mission then
        local mission_name = Managers.state.mission:mission_name()
        if mission_name then
            local mission_settings = Missions[mission_name]
            if mission_settings then
                mod.isInMission = not mission_settings.is_hub
            end
        end
    end
end

mod.update = function(dt)
    if mod.initialized then
        return
    end

    initMod()
end


mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateMainMenu" and status == "enter" then
        -- game loaded, user is at the character selector menu
        initMod()
    elseif state_name == "GameplayStateRun" and status == "enter" then
        -- mission started
        if not mod.initialized then
            return
        end

        local mission_name = Managers.state.mission:mission_name()
        local mission_settings = Missions[mission_name]
        mod.isInMission = not mission_settings.is_hub
    elseif state_name == "StateGameplay" and status == "exit" then
        -- mission ended
        if mod.initialized and mod.isInMission then
            mod.isInMission = false
            mod.teammates = nil
            persist_rating()
        end
    end
end

local function formatPlayerName(originalName, accountId)
    if not mod.rating then
        return originalName
    end

    local accData = mod.rating.accounts[accountId]
    if not accData then
        return originalName
    end

    -- clean originalName (color, etc.)
    if accData.rating == RATING.AVOID then
        return "{#color(255,20,20)}" .. SYMBOLS.SKULL .. "{#reset()} " .. originalName
    end

    error('Unsupported rating type:' .. tostring(accData.rating))
end

mod:command("lmn_cmd", "(lovesmenot) Get property on local player object", function(modProperty, subProperty)
    local value = mod[modProperty]
    if subProperty then
        value = value[subProperty]
    end

    mod:echo(json.encode(value))
end)

mod:command("lmn_save", "(lovesmenot) Save state to file", function()
    persist_rating()
end)

-- mod:dump_to_file(player, string.format("%s-player-syncplayer", characterId), 4)

-- player joins the lobby
-- remarks: here we don't have to worry about bots because they join after the game has started
-- TODO: _assign_player_to_slot() maybe?
mod:hook_safe(CLASS.LobbyView, "_sync_player", function(self, unique_id, player)
    if not mod.initialized then return end

    local spawnSlots = self._spawn_slots
    local slotId = self:_player_slot_id(unique_id)
    local slot = spawnSlots[slotId]
    local content = slot.panel_widget.content

    content.character_name = formatPlayerName(plyer:profile().name, player._account_id)
end)

-- player joins midgame
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
                content.text = formatPlayerName(characterName, accountId)
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

                content.header_text = formatPlayerName(player:profile().name, player._telemetry_subject.account_id)
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
                    content.character_name = formatPlayerName(player_info:profile().name, account_id)
                end
            end
        end
    end
end)

local function update_rating(teammate)
    if mod.rating == nil then
        mod.rating = {
            version = CURRENT_VERSION,
            accounts = {}
        }
    end

    local message
    if not mod.rating.accounts[teammate.accountId] then
        -- account has not been rated yet, create object
        mod.rating.accounts[teammate.accountId] = {
            rating = RATING.AVOID
        }
        message = mod:localize("rate_notification_text_set", teammate.name, mod:localize("rating_value_avoid"))
        message = "{#color(255,20,20)}" .. SYMBOLS.SKULL .. "{#reset()} " .. message
    else
        -- account was rated, remove from table
        mod.rating.accounts[teammate.accountId] = nil
        message = mod:localize("rate_notification_text_unset", teammate.name)
        message = SYMBOLS.CHECK .. " " .. message
    end

    -- user feedback
    direct_notification(message)

    -- update team panel to show changes
end

local function rate_teammate(teammateIndex)
    if not mod.initialized or not mod.isInMission then
        return
    end

    local selected
    if teammateIndex == 1 and #mod.teammates > 0 then
        selected = mod.teammates[teammateIndex]
    elseif teammateIndex == 2 and #mod.teammates > 1 then
        selected = mod.teammates[teammateIndex]
    elseif teammateIndex == 3 and #mod.teammates > 2 then
        selected = mod.teammates[teammateIndex]
    end

    update_rating(selected)
end

function mod.rate_teammate_1() rate_teammate(1) end

function mod.rate_teammate_2() rate_teammate(2) end

function mod.rate_teammate_3() rate_teammate(3) end
