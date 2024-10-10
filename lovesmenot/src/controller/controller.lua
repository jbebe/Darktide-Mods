---@module 'lovemenot/src/types/dmf-types'
---@module 'lovemenot/src/types/darktide-types'
---@module 'lovemenot/src/constants'

local md5 = modRequire 'lovesmenot/nurgle_modules/md5'
local fun = modRequire 'lovesmenot/nurgle_modules/fun'
local langUtils = modRequire 'lovesmenot/src/utils/language'
local utils = modRequire 'lovesmenot/src/utils/language'

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

---@alias CommunityRating table<string, RATINGS>
---@alias SyncableRating table<string, SyncableRatingItem>

---@class CachedInfo
---@field idHash string
---@field level number | nil

---@class LovesMeNot
---@field dmf DmfMod | table<string, function>
---@field localPlayer HumanPlayer | nil
---@field initialized boolean
---@field localRating LocalRating | nil
---@field communityRating CommunityRating | nil
---@field syncableRating SyncableRating | nil
---@field accountCache table<string, CachedInfo>
---@field teammates table
---@field isInMission boolean
---@field debugging boolean
---@field loadLocalRating function
---@field downloadCommunityRating function
---@field persistLocalRating function
---@field reinit function
---@field registerRatingsView function
---@field openRatings function
---@field updateLocalRating fun(self: LovesMeNot, teammate: Teammate)
---@field updateCommunityRating fun(self: LovesMeNot, teammate: Teammate): boolean
---@field uploadCommunityRating fun(self: LovesMeNot): boolean
---@field formatPlayerName fun(self: LovesMeNot, oldText: string, accountId: string, characterId: string): string, boolean
---@field rateTeammate fun(self: LovesMeNot, teammateIndex: number)
---@field md5 { sumhexa: fun(text: string): string }
---@field reef string | nil
---@field logFileHandle file* | nil
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
    accountCache = {},
    syncableRating = {},
    localRating = nil,
    communityRating = nil,
    reef = nil,
    localPlayerFriends = {},
}

function controller:getConfigPath()
    local appDataPath = utils.os.getenv('APPDATA')
    if IS_GDK then
        return appDataPath .. [[\Fatshark\MicrosoftStore\Darktide]]
    else
        return appDataPath .. [[\Fatshark\Darktide]]
    end
end

---@type table<LogLevel, number>
local LogLevelMap = {
    debug = 1,
    info = 2,
    warning = 3,
    error = 4,
}

---@param level LogLevel
---@param message string
function controller:log(level, message)
    local logLevel = self.dmf:get('lovesmenot_settings_loglevel')
    if LogLevelMap[level] < LogLevelMap[logLevel] then
        return
    end

    local loggedLine = ('[%s] %s'):format(
        level,
        type(message) == 'table' and table.tostring(message) or tostring(message)
    );
    print('[lovesmenot]' .. loggedLine)
    self.logFileHandle:write(loggedLine .. '\n')
end

---@param accountId string
function controller:hash(accountId)
    local cleanedId, _ = accountId:lower():gsub('[^0-9a-f]+', '')
    return self.md5.sumhexa(cleanedId)
end

function controller:canRate()
    return self.initialized and self.isInMission
end

function controller:isCommunity()
    local isCommunity = self.dmf:get('lovesmenot_settings_community')
    return isCommunity
end

---@return string | nil
function controller:getAccessToken()
    return self.dmf:get('lovesmenot_settings_community_access_token')
end

function controller:hasRating()
    if self:isCommunity() then
        return self.communityRating ~= nil
    else
        return self.localRating ~= nil
    end
end

---@param accountId string
---@param level number | nil
---@return CachedInfo
function controller:addAccountCache(accountId, level)
    local cache = self.accountCache[accountId]
    if cache then
        cache.level = level or cache.level
    else
        cache = {
            level = level or 1,
            idHash = self:hash(accountId),
        }
    end
    self.accountCache[accountId] = cache

    return cache
end

---@param accountId string
---@param overrideLevel number | nil
---@return RATINGS | nil, boolean | nil (rating, isCommunityRating)
function controller:getRating(accountId, overrideLevel)
    -- Return local rating if exists
    local rating = langUtils.coalesce(self.localRating, 'accounts', accountId, 'rating')
    if rating then
        return rating
    end

    -- If community sync is enabled, fall back to it if local rating is not found
    if self:isCommunity() then
        local cache = self:addAccountCache(accountId, overrideLevel)

        if self:hasRating() then
            local communityRating = self.communityRating[cache.idHash]
            if communityRating then
                -- show rating with web icon if account has community rating
                return communityRating, true
            end
        end
    end
end

function controller:loadLocalPlayerToCache()
    local backend_interface = Managers.backend.interfaces
    local promise = backend_interface.progression:get_entity_type_progression('character')
    promise:next(function(characters_progression)
        -- Find character with highest level
        ---@type CharacterProgression
        local progression = fun.maximum_by(
        ---@param a CharacterProgression
        ---@param b CharacterProgression
            function(a, b)
                if a.currentLevel > b.currentLevel then
                    return a
                else
                    return b
                end
            end,
            characters_progression)

        -- Set rating of host player
    end):catch(function(error)
        print(table.tostring(error, 5))
    end)
end

function controller:hideOwnRating()
    return self.dmf:get('lovesmenot_settings_community_hide_own_rating')
end

return controller
