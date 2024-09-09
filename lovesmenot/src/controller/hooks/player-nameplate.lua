---@param controller LovesMeNot
local function init(controller)
    -- player name above their head
    local _get_markers_by_id = function()
        local ui_manager = Managers.ui
        local hud = ui_manager:get_hud()
        local world_markers = hud and hud:element('HudElementWorldMarkers')
        local markers_by_id = world_markers and world_markers._markers_by_id

        return markers_by_id
    end
    controller.dmf:hook_safe(CLASS.HudElementNameplates, 'update', function(self, dt, t)
        if not controller.timers:canRun('HudElementNameplates_update', t, 2) then return end
        if not controller.initialized then return end

        local nameplates = self._nameplate_units
        local markers_by_id = _get_markers_by_id()

        for _, data in pairs(nameplates) do
            local id = data.marker_id
            local marker = markers_by_id[id]

            if marker then
                local player = marker.data
                local player_deleted = player.__deleted

                if not player_deleted then
                    local widget = marker.widget
                    local content = widget.content

                    local newName, isDirty =
                        controller:formatPlayerName(content.header_text, player._telemetry_subject.account_id)
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
