---@param controller LovesMeNot
local function init(controller)
    local getMarkersById = function()
        local hud = Managers.ui:get_hud()
        local worldMarkers = hud and hud:element('HudElementWorldMarkers')
        return worldMarkers and worldMarkers._markers_by_id
    end

    -- player name above players' head
    controller.dmf:hook_safe(CLASS.HudElementNameplates, 'update', function(self, dt, t)
        if not controller.timers:canRun('HudElementNameplates_update', t, 2) then return end
        if not controller.initialized then return end

        local markersById = getMarkersById()
        if markersById then
            for _, data in pairs(self._nameplate_units) do
                local marker = markersById[data.marker_id]
                if marker and not marker.data.__deleted then
                    ---@type RemotePlayer
                    local player = marker.data
                    local profile = player:profile()
                    if profile and player:is_human_controlled() then
                        local playerInfo = Managers.data_service.social:get_player_info_by_account_id(
                            player:account_id()
                        )
                        local platform = playerInfo:platform()
                        local platformId = playerInfo:platform_user_id()
                        local uid = controller:uid(platform, platformId)
                        local widget = marker.widget
                        local content = widget.content

                        local newName, isDirty = controller:formatPlayerName(
                            content.header_text, uid, profile.current_level)
                        if isDirty then
                            content.header_text = newName
                            widget.dirty = true
                        end
                    end
                end
            end
        end
    end)
end

return init
