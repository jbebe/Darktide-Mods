local json = modRequire 'lovesmenot/nurgle_modules/json'
local utils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    local ratingPath = utils.os.getenv('APPDATA') .. [[\Fatshark\Darktide\lovesmenot.json]]

    function controller:loadRating()
        local file = utils.io.open(ratingPath, 'r')
        if file ~= nil then
            local rawContent = file:read('*all')
            file:close()
            -- ignore version as of now, no migration needed yet
            self.rating = json.decode(rawContent)
        else
            -- file does not exist
        end
    end

    -- TODO: use coroutine debounce and save json more often
    -- https://www.lua.org/pil/9.1.html
    function controller:persistRating()
        if not self.rating then
            return
        end

        local jsonData = json.encode(self.rating)
        local file = assert(utils.io.open(ratingPath, 'w'))
        file:write(jsonData)
        file:close()
    end
end

return init
