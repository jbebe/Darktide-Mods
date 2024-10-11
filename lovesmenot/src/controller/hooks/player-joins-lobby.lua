---@param controller LovesMeNot
local function init(controller)
    -- player joins the lobby
    -- remarks: here we don't have to worry about bots because they join after the game has started
    ---@param player HumanPlayer | RemotePlayer
    controller.dmf:hook_safe(CLASS.LobbyView, '_sync_player', function(self, unique_id, player)
        if not controller.initialized then return end

        local playerInfo = Managers.data_service.social:get_player_info_by_account_id(player:account_id())
        local profile = player:profile()
        local platform = playerInfo:platform()
        local platformId = playerInfo:platform_user_id()
        local uid = controller:uid(platform, platformId)

        -- format player name
        local spawnSlots = self._spawn_slots
        local slotId = self:_player_slot_id(unique_id)
        local slot = spawnSlots[slotId]
        local content = slot.panel_widget.content
        local characterId = profile and profile.character_id
        content.character_name, _ = controller:formatPlayerName(content.character_name, uid, profile.current_level)
    end)
end

return init
