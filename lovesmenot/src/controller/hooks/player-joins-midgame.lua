---@param controller LovesMeNot
local function init(controller)
    -- Player joins midgame
    controller.dmf:hook_safe(CLASS.HudElementTeamPanelHandler, 'update',
        function(self, dt, t, ui_renderer, render_settings, input_service)
            if not controller.timers:canRun('HudElementTeamPanelHandler_update', t, 2) then return end
            if not controller.initialized then return end

            ---@type Teammate[]
            local communityPlayers = {}
            local teammatesChanged = false
            for idx, data in ipairs(self._player_panels_array) do
                ---@type PlayerInfo
                local player = data.player
                local platform = player:platform()
                local platformId = player:platform_user_id()
                local uid = controller:uid(platform, platformId)
                print('classname: ' .. player.__class_name)
                local isBot = not player:is_human_controlled()
                if not isBot then
                    local panel = data.panel
                    local widget = panel._widgets_by_name.player_name
                    local content = widget.content
                    local profile = player:profile()

                    -- Format name (host player, optionally)
                    local showHostPlayerRating = not controller:hideOwnRating()
                    local isHostPlayer = platformId == controller.ownUid
                    if not isHostPlayer or showHostPlayerRating then
                        local character_id = profile and profile.character_id
                        local newName, isDirty = controller:formatPlayerName(content.text, uid, character_id)
                        if isDirty then
                            content.text = newName
                            widget.dirty = isDirty
                        end
                    end

                    -- add other players to teammates list if neccessary
                    local teammateAtIndex = controller.teammates[idx]
                    local shouldCreateTeammate = teammateAtIndex == nil or teammateAtIndex.uid ~= uid
                    if not isHostPlayer and shouldCreateTeammate then
                        local characterName = profile.name
                        ---@type Teammate
                        local teammate = {
                            uid = uid,
                            name = player._presence:account_name(),
                            platform = platform,
                            platformId = platformId,
                            characterName = characterName,
                            characterType = profile.archetype.name,
                            characterLevel = profile.current_level,
                        }
                        table.insert(communityPlayers, teammate)
                        teammatesChanged = true
                    end
                end
            end

            if teammatesChanged then
                controller.teammates = communityPlayers
            end
        end)
end

return init
