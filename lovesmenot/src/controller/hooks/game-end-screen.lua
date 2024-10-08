---@param controller LovesMeNot
local function init(controller)
    -- game end screen
    controller.dmf:hook_safe(CLASS.EndView, '_set_character_names', function(self)
        if not controller.initialized then return end

        local spawn_slots = self._spawn_slots
        if spawn_slots then
            for _, slot in ipairs(spawn_slots) do
                local widget = slot.widget

                if widget then
                    local content = widget.content
                    local account_id = slot.account_id
                    ---@type HumanPlayer
                    local player_info = slot.player_info
                    local profile = player_info:profile()
                    local character_id = profile and profile.character_id
                    ---@type CharacterProgression
                    controller:addAccountCache(account_id, profile.current_level)
                    if account_id ~= controller.localPlayer:account_id() then
                        local newName, isDirty =
                            controller:formatPlayerName(content.character_name, account_id, character_id)
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
