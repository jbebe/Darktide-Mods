local mod = get_mod("lovesmenot")
local json = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/thirdparty/json")
local utils = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/utils")

function mod.load_rating(self)
    local file = utils.io.open(self.ratingPath, "r")
    if file ~= nil then
        local rawContent = file:read("*all")
        file:close()
        -- ignore version as of now, no migration needed yet
        self.rating = json.decode(rawContent)
    else
        -- file does not exist
    end
end

-- TODO: use coroutine debounce and save json more often
-- (https://www.lua.org/pil/9.1.html)
function mod.persist_rating(self)
    if not self.rating then
        return
    end

    local jsonData = json.encode(self.rating)
    local file = assert(utils.io.open(self.ratingPath, "w"))
    file:write(jsonData)
    file:close()
end
