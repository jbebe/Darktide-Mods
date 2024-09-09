local Missions = require('scripts/settings/mission/mission_templates')
local UISoundEvents = require('scripts/settings/ui/ui_sound_events')

local utils = {}

-- Checks if the player is currently in a mission and that mission is not the Mourningstar
function utils.isInRealMission()
    ---@type Managers
    local managers = Managers
    if managers.state.mission then
        local mission_name = managers.state.mission:mission_name()
        if mission_name then
            local mission_settings = Missions[mission_name]
            if mission_settings then
                return not mission_settings.is_hub
            end
        end
    end

    return false
end

-- Shows the notification bar at the middle right of the screen without DMF intercepting it
function utils.directNotification(message, isError)
    ---@type Managers
    local managers = Managers
    if managers.event then
        if not isError then
            Managers.event:trigger(
                'event_add_notification_message',
                'default',
                message,
                nil,
                UISoundEvents.default_click)
        else
            Managers.event:trigger(
                'event_add_notification_message',
                'alert',
                { text = message } or '',
                nil,
                UISoundEvents.default_click
            )
        end
    end
end

return utils
