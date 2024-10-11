local UISoundEvents = require 'scripts/settings/ui/ui_sound_events'

local utils = {}

-- Shows the notification bar at the middle right of the screen without DMF intercepting it
---@param message string
---@param isError boolean | nil
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
