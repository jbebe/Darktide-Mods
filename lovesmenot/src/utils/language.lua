local DMF = get_mod('DMF')

---@class LanguageUtilsType
---@field io iolib
---@field os oslib
---@field ffi any
---@field loadstring fun(input: string): (fun(): unknown)
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
load_lua_lib('ffi')
load_lua_lib('loadstring')

function utils.startsWith(haystack, needle)
    return haystack:sub(1, #needle) == needle
end

---@param obj table
function utils.coalesce(obj, ...)
    local current = obj
    local props = { ... }
    for _, propertyName in ipairs(props) do
        if current == nil then
            return nil
        end
        current = current[propertyName]
    end
    return current
end

function utils.keys(obj)
    local keys = {}
    for key, _ in pairs(obj) do
        table.insert(keys, key)
    end
    return keys
end

function utils.values(obj)
    local values = {}
    for _, value in pairs(obj) do
        table.insert(values, value)
    end
    return values
end

function utils.isEmpty(t)
    return next(t) == nil
end

return utils
