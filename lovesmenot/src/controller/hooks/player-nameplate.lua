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
        for _, data in pairs(self._nameplate_units) do
            local marker = markersById[data.marker_id]
            if marker then
                ---@type PlayerInfo
                local player = marker.data
                local isPlayerDeleted = player.__deleted
                if not isPlayerDeleted then
                    local widget = marker.widget
                    local content = widget.content
                    local characterId = player:profile().character_id

                    local newName, isDirty = controller:formatPlayerName(
                        content.header_text, player:platform_user_id(), characterId)
                    if isDirty then
                        content.header_text = newName
                        widget.dirty = true
                    end
                end
            end
        end
    end)
end

return init
