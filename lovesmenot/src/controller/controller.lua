---@module 'lovemenot/src/types/dmf-types'
---@module 'lovemenot/src/types/darktide-types'
---@module 'lovemenot/src/constants'

local md5 = modRequire 'lovesmenot/nurgle_modules/md5'
local fun = modRequire 'lovesmenot/nurgle_modules/fun'
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

---@class Teammate
---@field accountId string
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType
---@field characterLevel number

---@class SyncableRatingItem
---@field level number
---@field idHash string
---@field rating RATINGS

---@alias RemoteRating table<string, RATINGS>
---@alias SyncableRating table<string, SyncableRatingItem>

---@class LovesMeNot
---@field dmf DmfMod | table<string, function>
---@field localPlayer HumanPlayer | nil
---@field initialized boolean
---@field localRating LocalRating | nil
---@field remoteRating RemoteRating | nil
---@field syncableRating SyncableRating | nil
---@field hashCache table<string, string> accountId -> hash cache
---@field teammates table
---@field isInMission boolean
---@field debugging boolean
---@field loadLocalRating function
---@field loadRemoteRating function
---@field persistLocalRating function
---@field reinit function
---@field registerRatingsView function
---@field openRatings function
---@field updateLocalRating fun(self: LovesMeNot, teammate: Teammate)
---@field updateRemoteRating fun(self: LovesMeNot, teammate: Teammate): boolean
---@field syncRemoteRating fun(self: LovesMeNot): boolean
---@field formatPlayerName fun(self: LovesMeNot, oldText: string, accountId: string, characterId: string): string, boolean
---@field rateTeammate fun(self: LovesMeNot, teammateIndex: number)
---@field md5 { sumhexa: fun(text: string): string }
local controller = {
    dmf = dmf,
    initialized = false,
    isInMission = false,
    localPlayer = nil,
    teammates = {},
    rating = nil,
    debugging = false,
    timers = timers,
    md5 = md5,
    hashCache = {},
    syncableRating = {},
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
---@param characterXp number | nil
---@return CachedInfo
function controller:addAccountCache(accountId, characterXp)
    local cache = self.accountCache[accountId]
    if cache then
        cache.characterXp = characterXp or cache.characterXp
    else
        cache = {
            characterXp = characterXp or 1,
            idHash = self:hash(accountId),
        }
    end
    self.accountCache[accountId] = cache

    return cache
end

---@param accountId string
---@param overrideXp number | nil
---@return RATINGS | nil, boolean | nil
function controller:getRating(accountId, overrideXp)
    -- Return local rating if exists
    local rating = langUtils.coalesce(self.localRating, 'accounts', accountId, 'rating')
    if rating then
        return rating
    end

    -- If cloud sync is enabled, fall back to it
    if self:isCloud() then
        local cache = self:addAccountCache(accountId, overrideXp)

        -- show rating with cloud icon if account has cloud rating
        local remoteRating = self.remoteRating[cache.idHash]
        if remoteRating then
            return remoteRating, true
        end
    end
end

function controller:loadLocalPlayerToCache()
    local backend_interface = Managers.backend.interfaces
    local promise = backend_interface.progression:get_entity_type_progression('character')
    promise:next(function(characters_progression)
        -- Find character with highest XP
        ---@type CharacterProgression
        local progression = fun.maximum_by(
        ---@param a CharacterProgression
        ---@param b CharacterProgression
            function(a, b)
                if a.currentXp > b.currentXp then
                    return a
                else
                    return b
                end
            end,
            characters_progression)

        -- Set rating of host player
        self:getRating(self.localPlayer:account_id(), progression.currentXp)
    end):catch(function(error)
        print(table.tostring(error, 5))
    end)
end

function controller:hideOwnRating()
    return self.dmf:get('lovesmenot_settings_cloud_sync_hide_own_rating')
end

return controller
