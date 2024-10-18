---@param controller LovesMeNot
local function init(controller)
    -- Player joins midgame
    controller.dmf:hook_safe(CLASS.HudElementTeamPanelHandler, 'update',
        function(self, dt, t, ui_renderer, render_settings, input_service)
            if not controller.timers:canRun('HudElementTeamPanelHandler_update', t, 2) then return end
            if not controller.initialized then return end

            ---@type Teammate[]
            local teammates = {}
            for _, data in pairs(self._player_panels_array) do
                ---@type HumanPlayer
                local player = data.player
                if not player.__deleted then
                    local profile = player:profile()
                    if not player:is_human_controlled() or not profile then
                        table.insert(teammates, false)
                    else
                        local playerInfo = Managers.data_service.social:get_player_info_by_account_id(player:account_id())
                        local platform = playerInfo:platform()
                        local platformId = playerInfo:platform_user_id()
                        local uid = controller:uid(platform, platformId)

                        local panel = data.panel
                        local widget = panel._widgets_by_name.player_name
                        local content = widget.content

                        -- Format name (host player, optionally)
                        local showHostPlayerRating = not controller:hideOwnRating()
                        local isHostPlayer = uid == controller.ownUid
                        if not isHostPlayer or showHostPlayerRating then
                            local newName, isDirty = controller:formatPlayerName(content.text, uid, profile
                                .current_level)
                            if isDirty then
                                content.text = newName
                                widget.dirty = isDirty
                            end
                        end

                        -- add other players to teammates list if neccessary
                        if not isHostPlayer then
                            local characterName = profile.name
                            ---@type Teammate
                            local teammate = {
                                uid = uid,
                                name = playerInfo._presence:account_name(),
                                platform = platform,
                                characterName = characterName,
                                characterType = profile.archetype.name,
                                characterLevel = profile.current_level,
                            }
                            table.insert(teammates, teammate)
                        end
                    end
                end
            end
            controller.teammates = teammates
        end
    )
end

return init
