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

                    if account_id ~= controller.localPlayer._account_id then
                        local newName, isDirty = controller:formatPlayerName(content.character_name, account_id)
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
