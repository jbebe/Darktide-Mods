---@param controller LovesMeNot
local function init(controller)
    -- Player joins the lobby
    -- Remarks: here we don't have to worry about bots because they join after the game has started
    ---@param player HumanPlayer
    controller.dmf:hook_safe(CLASS.LobbyView, '_sync_player', function(self, unique_id, player)
        if not controller.initialized then return end

        local spawnSlots = self._spawn_slots
        local slotId = self:_player_slot_id(unique_id)
        local slot = spawnSlots[slotId]
        local content = slot.panel_widget.content
        local profile = player:profile()
        local character_id = profile and profile.character_id

        content.character_name, _ =
            controller:formatPlayerName(content.character_name, player:account_id(), character_id)
    end)
end

return init
