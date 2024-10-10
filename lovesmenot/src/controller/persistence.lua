local json = modRequire 'lovesmenot/nurgle_modules/json'
local utils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    local ratingPath = controller:getConfigPath() .. [[\lovesmenot.json]]

    function controller:loadLocalRating()
        local file = utils.io.open(ratingPath, 'r')
        if file ~= nil then
            local rawContent = file:read('*all')
            file:close()
            -- ignore version as of now, no migration needed yet
            self.localRating = json.decode(rawContent)
        else
            -- file does not exist
        end
    end

    -- TODO: use coroutine debounce and save json more often?
    -- https://www.lua.org/pil/9.1.html
    function controller:persistLocalRating()
        if not self.localRating then
            return
        end

        local jsonData = json.encode(self.localRating)
        local file = assert(utils.io.open(ratingPath, 'w'))
        file:write(jsonData)
        file:close()
    end
end

return init
