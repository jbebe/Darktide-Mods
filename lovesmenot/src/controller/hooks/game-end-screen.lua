---@param controller LovesMeNot
local function init(controller)
    -- game end screen
    controller.dmf:hook_safe(CLASS.EndView, '_set_character_names', function(self)
        if not controller.initialized then return end

        local session_report = self._session_report
        local session_report_raw = session_report and session_report.eor
        local participant_reports = session_report_raw and session_report_raw.team.participants
        local spawn_slots = self._spawn_slots

        if spawn_slots then
            for _, slot in ipairs(spawn_slots) do
                local widget = slot.widget

                if widget then
                    local content = widget.content
                    local account_id = slot.account_id
                    local player_info = slot.player_info
                    local profile = player_info:profile()
                    local character_id = profile and profile.character_id
                    ---@type CharacterProgression
                    local report = self:_get_participant_progression(participant_reports, account_id)
                    controller:addAccountCache(account_id, report.currentXp)

                    if account_id ~= controller.localPlayer._account_id then
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
