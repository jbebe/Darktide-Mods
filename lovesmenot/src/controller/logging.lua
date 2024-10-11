local gameUtils = modRequire 'lovesmenot/src/utils/game'
local langUtils = modRequire 'lovesmenot/src/utils/language'
local constants = modRequire 'lovesmenot/src/constants'

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
            gameUtils.directNotification('LovesMeNot error happened, disabling mod', true)
            self.logFileHandle:flush()
            self.initialized = false
        end
    end

    -- load log file
    if controller.logFileHandle ~= nil then
        controller:log('info', 'Log file closed', 'controller:init')
        controller.logFileHandle:close()
    end
    local ratingPath = controller:getConfigPath() .. [[\lovesmenot.log]]
    controller.logFileHandle = langUtils.io.open(ratingPath, 'a')
    controller.logFileHandle:write('- - - - - - - - - - - - - - - - - -\n')
    controller.logFileHandle:write(('- LOG START: %s  -\n'):format(langUtils.os.date(constants.DATE_FORMAT)))
    controller.logFileHandle:write('- - - - - - - - - - - - - - - - - -\n')
    controller:log('info', 'Log file opened', 'controller:init')
end

return init
