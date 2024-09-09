local DMF = get_mod('DMF')

---@class LanguageUtilsType
---@field io iolib
---@field os oslib
local utils = {}

function utils.traceback()
    local level = 1
    while true do
        local info = debug.getinfo(level, 'Sl')
        if not info then break end
        if info.what == 'C' then
            print(level, 'C function')
        else
            print(('[%s]:%d'):format(info.short_src, info.currentline))
        end
        level = level + 1
    end
end

local function load_lua_lib(libName)
    utils[libName] = DMF:persistent_table('_' .. libName)
    utils[libName].initialized = utils[libName].initialized or false
    if not utils[libName].initialized then
        ---@type Mods
        local mods = Mods
        utils[libName] = DMF.deepcopy(mods.lua[libName])
    end
end

load_lua_lib('io')
load_lua_lib('os')

function utils.startsWith(haystack, needle)
    return haystack:sub(1, #needle) == needle
end

return utils
