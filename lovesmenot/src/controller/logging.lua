local gameUtils = modRequire 'lovesmenot/src/utils/game'

---@param controller LovesMeNot
local function init(controller)
    ---@type table<LogLevel, number>
    local LogLevelMap = {
        debug = 1,
        info = 2,
        warning = 3,
        error = 4,
    }

    function controller:log(level, message, category)
        local logLevel = self.dmf:get('lovesmenot_settings_loglevel')
        if LogLevelMap[level] < LogLevelMap[logLevel] then
            return
        end
        local stringifiedMessage = type(message) == 'table' and table.tostring(message) or tostring(message)
        local loggedLine = ('[%s][%s] %s'):format(category or 'global', level, stringifiedMessage);
        print('[lovesmenot]' .. loggedLine)
        self.logFileHandle:write(loggedLine .. '\n')

        -- pause mod if error happened
        if level == 'error' then
            gameUtils.directNotification('LovesMeNot error happened, stopping scripts', true)
            self.logFileHandle:flush()
            self.initialized = false
        end
    end
end

return init
