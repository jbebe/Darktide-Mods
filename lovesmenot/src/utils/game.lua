local Missions = require 'scripts/settings/mission/mission_templates'
local UISoundEvents = require 'scripts/settings/ui/ui_sound_events'

local utils = {}

-- Shows the notification bar at the middle right of the screen without DMF intercepting it
---@param message string
---@param isError boolean | nil
---@param delaySec number | nil
function utils.directNotification(message, isError, delaySec)
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
                UISoundEvents.default_click,
                nil,
                delaySec
            )
        end
    end
end

-- Checks if the player is currently in a mission and that mission is not the Mourningstar
function utils.isInMission()
    ---@type Managers
    local managers = Managers
    if managers.state.mission then
        local mission_name = managers.state.mission:mission_name()
        if mission_name then
            local mission_settings = Missions[mission_name]
            return mission_settings ~= nil
        end
    end

    return false
end

function utils.createTimer()
    ---@class TimersType
    ---@field functions table<string, number>
    local timers = {
        functions = {}
    }

    -- Whether the execution of code should be debounced by given seconds
    -- We can save execution time by skipping logic when not really needed
    function timers:canRun(functionName, currentSecs, sleepSecs)
        local lastTick = self.functions[functionName]
        if not lastTick then
            -- first call
            self.functions[functionName] = currentSecs
            return true
        end

        if (currentSecs - lastTick) >= sleepSecs then
            -- called after delay achieved
            self.functions[functionName] = currentSecs
            return true
        end

        -- called before delay achieved
        return false
    end

    return timers
end

return utils
