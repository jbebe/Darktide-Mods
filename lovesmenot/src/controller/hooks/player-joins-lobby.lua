---@param controller LovesMeNot
local function init(controller)
    -- player joins the lobby
    -- remarks: here we don't have to worry about bots because they join after the game has started
    ---@param player PlayerInfo
    controller.dmf:hook_safe(CLASS.LobbyView, '_sync_player', function(self, unique_id, player)
        if not controller.initialized then return end

        local profile = player:profile()
        local platform = player:platform()
        local platformId = player:platform_user_id()
        local uid = controller:uid(platform, platformId)

        -- format player name
        local spawnSlots = self._spawn_slots
        local slotId = self:_player_slot_id(unique_id)
        local slot = spawnSlots[slotId]
        local content = slot.panel_widget.content
        local characterId = profile and profile.character_id
        content.character_name, _ = controller:formatPlayerName(content.character_name, uid, characterId)
    end)
end

return init
