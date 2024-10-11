---@param controller LovesMeNot
local function init(controller)
    -- game end screen
    -- remarks: here we don't have to worry about bots because they join after the game has started
    controller.dmf:hook_safe(CLASS.EndView, '_set_character_names', function(self)
        if not controller.initialized then return end

        local spawn_slots = self._spawn_slots
        if spawn_slots then
            for _, slot in ipairs(spawn_slots) do
                local widget = slot.widget
                if widget then
                    ---@type PlayerInfo
                    local player_info = slot.player_info
                    local platform = player_info:platform()
                    local platformId = player_info:platform_user_id()
                    local uid = controller:uid(platform, platformId)
                    local profile = player_info:profile()

                    -- show formatted player name
                    if uid ~= controller.ownUid then
                        local content = widget.content
                        local newName, isDirty =
                            controller:formatPlayerName(content.character_name, uid, profile.character_id)
                        if isDirty then
                            content.character_name = newName
                            widget.dirty = true
                        end
                    end
                end
            end
        end
    end)
end

return init
