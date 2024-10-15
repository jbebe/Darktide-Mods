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
        local loggedLine = ('[%s][%s] %s'):format(level, category or 'global', stringifiedMessage);
        print('[lovesmenot]' .. loggedLine)
        self.logFileHandle:write(loggedLine .. '\n')
    end

    function controller:initLogging()
        -- load log file
        if self.logFileHandle ~= nil then
            self:log('info', 'Log file closed', 'controller:initLogging')
            self.logFileHandle:close()
        end
        local ratingPath = self:getConfigPath() .. [[\lovesmenot.log]]
        self.logFileHandle = langUtils.io.open(ratingPath, 'a')
        self.logFileHandle:write('- - - - - - - - - - - - - - - - - -\n')
        self.logFileHandle:write(('- LOG START: %s  -\n'):format(langUtils.os.date(constants.DATE_FORMAT)))
        self.logFileHandle:write('- - - - - - - - - - - - - - - - - -\n')
        self:log('info', 'Log file opened', 'controller:initLogging')
    end
end

return init
