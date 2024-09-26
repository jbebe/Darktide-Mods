---@param controller LovesMeNot
local function init(controller)
    -- Player joins midgame
    -- TODO: this is just for debugging. move new player update to a less frequent function to avoid performance hit ()
    --       or we can keep this one but don't set widget dirty to true if character name is already highlighted
    controller.dmf:hook_safe(CLASS.HudElementTeamPanelHandler, 'update',
        function(self, dt, t, ui_renderer, render_settings, input_service)
            if not controller.timers:canRun('HudElementTeamPanelHandler_update', t, 2) then return end
            if not controller.initialized then return end

            local remotePlayers = {}
            for _, data in ipairs(self._player_panels_array) do
                local player = data.player
                local accountId = player:account_id()
                accountId = player._telemetry_subject.account_id -- DEBUG ONLY
                if accountId ~= nil and accountId ~= controller.localPlayer._account_id then
                    local profile = player:profile()
                    local character_id = profile and profile.character_id
                    local characterName = profile.name
                    local playerInfo = Managers.data_service.social:get_player_info_by_account_id(accountId)
                    if playerInfo then
                        local accountName = playerInfo._presence:account_name()
                        local platform = playerInfo:platform() or 'unknown'
                        table.insert(remotePlayers, {
                            accountId = accountId,
                            name = accountName,
                            platform = platform,
                            characterName = characterName,
                            characterType = profile.archetype.name,
                        })

                        local panel = data.panel
                        local widget = panel._widgets_by_name.player_name
                        local content = widget.content

                        -- change name
                        local newName, isDirty = controller:formatPlayerName(content.text, accountId, character_id)
                        if isDirty then
                            content.text = newName
                            widget.dirty = isDirty

                            -- expand name container
                            local container_size = widget.style.text.size
                            if container_size then
                                container_size[1] = 500
                            end
                        end
                    end
                end
            end

            controller.teammates = remotePlayers
        end)
end

return init
