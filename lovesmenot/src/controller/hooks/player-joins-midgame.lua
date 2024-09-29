---@param controller LovesMeNot
local function init(controller)
    -- Player joins midgame
    controller.dmf:hook_safe(CLASS.HudElementTeamPanelHandler, 'update',
        function(self, dt, t, ui_renderer, render_settings, input_service)
            if not controller.timers:canRun('HudElementTeamPanelHandler_update', t, 2) then return end
            if not controller.initialized then return end

            local remotePlayers = {}
            for _, data in ipairs(self._player_panels_array) do
                local player = data.player
                local accountId = player:account_id()
                local isBot = accountId == nil
                if not isBot then
                    local panel = data.panel
                    local widget = panel._widgets_by_name.player_name
                    local content = widget.content
                    local profile = player:profile()

                    -- Format name (host player, optionally)
                    local showHostPlayerRating = not controller:hideOwnRating()
                    local isHostPlayer = accountId == controller.localPlayer._account_id
                    if not isHostPlayer or showHostPlayerRating then
                        local character_id = profile and profile.character_id
                        local newName, isDirty = controller:formatPlayerName(content.text, accountId, character_id)
                        if isDirty then
                            content.text = newName
                            widget.dirty = isDirty
                        end
                    end

                    -- add other players to teammates list
                    if not isHostPlayer then
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
                        end
                    end
                end
            end

            -- TODO: only update teammates if something has changed
            controller.teammates = remotePlayers
        end)
end

return init
