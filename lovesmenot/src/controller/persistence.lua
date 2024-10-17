local json = modRequire 'lovesmenot/nurgle_modules/json'

local utils = modRequire 'lovesmenot/src/utils/language'
local gameUtils = modRequire 'lovesmenot/src/utils/game'
local langUtils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    function controller:getConfigPath()
        local appDataPath = langUtils.os.getenv('APPDATA')
        if IS_GDK then
            return appDataPath .. [[\Fatshark\MicrosoftStore\Darktide]]
        else
            return appDataPath .. [[\Fatshark\Darktide]]
        end
    end

    local ratingPath = controller:getConfigPath() .. [[\lovesmenot.json]]

    function controller:loadLocalRating()
        local file = utils.io.open(ratingPath, 'r')
        if file ~= nil then
            local rawContent = file:read('*all')
            file:close()
            -- ignore version as of now, no migration needed yet
            self.localRating = json.decode(rawContent)
        else
            self:log('info', 'Local rating file does not exist, skipping', 'controller:loadLocalRating')
        end
    end

    function controller:persistLocalRating()
        if not self.localRating then
            return
        end

        gameUtils.directNotification(
            controller.dmf:localize('lovesmenot_ingame_local_persist_success')
        )
        local jsonData = json.encode(self.localRating)
        local file = assert(utils.io.open(ratingPath, 'w'))
        file:write(jsonData)
        file:close()
    end
end

return init
