---@module 'lovemenot/src/types/dmf-types'
---@module 'lovemenot/src/types/darktide-types'
---@module 'lovemenot/src/constants'

local md5 = modRequire 'lovesmenot/nurgle_modules/md5'
local langUtils = modRequire 'lovesmenot/src/utils/language'

---@type DmfMod
local dmf = get_mod('lovesmenot')

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

---@module 'lovemenot/src/constants'

---@alias PlatformType
---| 'steam'
---| 'xbox'
---| 'psn'
---| 'unknown'

---@alias CharacterType
---| 'zealot'
---| 'veteran'
---| 'psyker'
---| 'ogryn'

---@class RatingAccount
---@field rating RATINGS
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType
---@field creationDate string

---@class LocalRating
---@field version number
---@field accounts table<string, RatingAccount>

---@class TeammateType
---@field accountId string
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType

---@alias RemoteRating table<string, RATINGS>

---@class LovesMeNot
---@field dmf DmfMod | table<string, function>
---@field localPlayer HumanPlayer | nil
---@field initialized boolean
---@field localRating LocalRating | nil
---@field remoteRating RemoteRating | nil
---@field teammates table
---@field isInMission boolean
---@field debugging boolean
---@field loadLocalRating function
---@field persistLocalRating function
---@field reinit function
---@field registerRatingsView function
---@field openRatings function
---@field updateRating fun(self: LovesMeNot, teammate: TeammateType)
---@field formatPlayerName fun(self: LovesMeNot, oldText: string, accountId: string): string, boolean
---@field rateTeammate fun(self: LovesMeNot, teammateIndex: number)
---@field md5 { sumhexa: fun(text: string): string }
---@field hashCache table<string, string>
local controller = {
    dmf = dmf,
    initialized = false,
    isInMission = false,
    localPlayer = nil,
    teammates = {},
    rating = nil,
    debugging = false,
    timers = timers,
    md5 = md5(langUtils.ffi),
    hashCache = {},
}

---@param accountId string
function controller:hash(accountId)
    local cleanedId, _ = accountId:lower():gsub('[^0-9a-f]+', '')
    return self.md5.sumhexa(cleanedId)
end

function controller:canRate()
    return self.initialized and self.isInMission
end

function controller:isCloud()
    local isCloud = self.dmf:get('lovesmenot_settings_cloud_sync')
    return isCloud
end

function controller:hasRating()
    if self:isCloud() then
        return self.remoteRating ~= nil
    else
        return self.localRating ~= nil
    end
end

---@param accountId string
function controller:getRating(accountId)
    if self:isCloud() then
        local cachedHash = self.hashCache[accountId]
        if cachedHash == nil then
            cachedHash = self:hash(accountId)
            self.hashCache[accountId] = cachedHash
        end

        return self.remoteRating[cachedHash]
    else
        return langUtils.coalesce(self.localRating, 'accounts', accountId, 'rating')
    end
end

return controller
