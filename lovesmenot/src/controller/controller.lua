---@module 'lovemenot/src/types/dmf-types'
---@module 'lovemenot/src/types/darktide-types'
---@module 'lovemenot/src/constants'

local RegionLatency = require 'scripts/backend/region_latency'

local md5 = modRequire 'lovesmenot/nurgle_modules/md5'
local fun = modRequire 'lovesmenot/nurgle_modules/fun'

local localization = modRequire 'lovesmenot/src/mod.localization'
local langUtils = modRequire 'lovesmenot/src/utils/language'
local gameUtils = modRequire 'lovesmenot/src/utils/game'

---@class LovesMeNot
---@field dmf DmfMod | table<string, function>
---@field logFileHandle file* | nil
---@field initialized boolean
---@field teammates Teammate[] Teammates list. Index 1,2,3 always refer to the right person, their position is fixed.
---@field localRating LocalRating | nil (key: uid) Local rating with detailed account information
---@field ownUid string | nil Host player's own uid (platform:platform_user_id)
---@field ownHash string | nil Host player's own hash
---@field communityRating CommunityRating (key: hash) Rating coming from the api in (hash, info) format
---@field syncableRating SyncableRating (key: hash) Syncable ratings we upload to the api (hash, info) format
---@field accountCache AccountCache (key: uid) Cached data for accounts. Hash and level is harder to get so we cache it.
---@field reef string | nil Metadata for the api
---@field localPlayerFriends string[] Host player's friend hash
---@field isInMission boolean Whether the host is in a level
---@field loadLocalRating fun(self: LovesMeNot)
---@field persistLocalRating fun(self: LovesMeNot)
---@field init fun(self: LovesMeNot, forceInit?: boolean)
---@field registerRatingsView fun(self: LovesMeNot)
---@field openRatings fun(self: LovesMeNot)
---@field updateLocalRating fun(self: LovesMeNot, teammate: Teammate)
---@field downloadCommunityRatingAsync fun(self: LovesMeNot): Promise
---@field updateCommunityRating fun(self: LovesMeNot, teammate: Teammate): boolean
---@field uploadCommunityRatingAsync fun(self: LovesMeNot): Promise
---@field formatPlayerName fun(self: LovesMeNot, oldText: string, uid: string, overrideLevel?: number): string, boolean (newName, isDirty)
---@field rateTeammate fun(self: LovesMeNot, teammateIndex: number)
---@field md5 { sumhexa: fun(text: string): string }
---@field getConfigPath fun(self: LovesMeNot): string
---@field log fun(self: LovesMeNot, level: LogLevel, message: string, category: string | nil)
local controller = {
    dmf = get_mod('lovesmenot'),
    initialized = false,
    isInMission = false,
    teammates = {},
    timers = gameUtils.createTimer(),
    md5 = md5,
    accountCache = {},
    syncableRating = {},
    communityRating = {},
    localPlayerFriends = {},
}

-- Getters

---@return boolean
function controller:isCommunity()
    local isCommunity = self.dmf:get('lovesmenot_settings_community') == true
    return isCommunity
end

---@return string | nil
function controller:getAccessToken()
    return self.dmf:get('lovesmenot_settings_community_access_token')
end

function controller:hideOwnRating()
    return self.dmf:get('lovesmenot_settings_community_hide_own_rating')
end

-- Initializer

function controller:init(forceInit)
    -- TODO: use flag for ongoing initialization & initialize = true when all promises ended
    if forceInit ~= true and self.initialized then
        controller:log('info', 'Mod is already initialized', 'controller:init')
        return
    end

    if Managers.backend._initialized ~= true then
        controller:log('info', 'BackendManager is not ready yet', 'controller:init')
        return
    end

    controller:log('info', 'Begin mod initialization', 'controller:init')

    local platform = Managers.data_service.social:platform()
    local platformId = Managers.account:platform_user_id()
    if platform == nil or platformId == nil then
        self:log('error', 'Gaming platform data is not available', 'controller:init')
        return
    else
        self.ownUid = controller:uid(platform, platformId)
        self.ownHash = controller:hash(self.ownUid)
    end

    -- load community rating
    if self:isCommunity() then
        RegionLatency:get_preferred_reef():next(function(data)
            self.reef = data
            self:log('info', 'Reef info loaded', 'controller:init/get_preferred_reef')
        end):catch(function(error)
            self:log('error', error.description, 'controller:init/get_preferred_reef')
        end)
        Managers.data_service.social:fetch_friends():next(function(friends)
            local friendsCache = {}
            local cacheIter = 1
            for i = 1, #friends do
                ---@type PlayerInfo
                local playerInfo = friends[i]
                local platform = playerInfo:platform()
                local isModdingAvailable = platform == 'steam' or platform == 'xbox'
                if isModdingAvailable then
                    local friendPlatformId = playerInfo:platform_user_id()
                    if friendPlatformId then
                        friendsCache[cacheIter] = self:hash(playerInfo:platform(), friendPlatformId)
                        cacheIter = cacheIter + 1
                    else
                        self:log('warning', 'Missing platform id', 'controller:init/fetch_friends')
                    end
                end
            end
            self.localPlayerFriends = friendsCache
            self:log('info', 'Friends cache loaded', 'controller:init/fetch_friends')
        end):catch(function(error)
            self:log('error', error.description, 'controller:init/fetch_friends')
        end)
        local accessToken = self:getAccessToken()
        if accessToken ~= nil then
            self:downloadCommunityRatingAsync()
            self:loadLocalPlayerToCache()
        else
            self:log('error', 'Missing access token, revert to local mode', 'controller:init')
            self.dmf:set('lovesmenot_settings_community', false, false)
            self:init()
            return
        end
    end

    -- load local rating
    self:loadLocalRating()

    -- load extras
    self.isInMission = gameUtils.isInMission()
    self:registerRatingsView()

    -- load localized string
    controller.dmf:add_global_localize_strings({
        lovesmenot_ratingsview_download_ratings = localization.lovesmenot_ratingsview_download_ratings,
        lovesmenot_ratingsview_download_ratings_notif = localization.lovesmenot_ratingsview_download_ratings_notif,
        lovesmenot_community_create_token_title = localization.lovesmenot_community_create_token_title,
        lovesmenot_community_create_token_description = localization.lovesmenot_community_create_token_description,
        lovesmenot_community_create_token_step_1 = localization.lovesmenot_community_create_token_step_1,
        lovesmenot_community_create_token_url = localization.lovesmenot_community_create_token_url,
        lovesmenot_community_create_token_step_2 = localization.lovesmenot_community_create_token_step_2,
        lovesmenot_community_create_token_step_3 = localization.lovesmenot_community_create_token_step_3,
        lovesmenot_community_create_token_save = localization.lovesmenot_community_create_token_save,
        lovesmenot_inspectview_options_rate = localization.lovesmenot_inspectview_options_rate,
        lovesmenot_ratingsview_title = localization.lovesmenot_ratingsview_title,
        lovesmenot_ratingsview_delete_title = localization.lovesmenot_ratingsview_delete_title,
        lovesmenot_ratingsview_delete_description = localization.lovesmenot_ratingsview_delete_description,
        lovesmenot_ratingsview_delete_yes = localization.lovesmenot_ratingsview_delete_yes,
        lovesmenot_ratingsview_delete_no = localization.lovesmenot_ratingsview_delete_no,
    })

    -- mod is initialized at this state
    -- pending promises may
    self.initialized = true
end

-- Methods

-- Creates a unique LovesMeNot id for player
---@param platform Platform
---@param platformId string
---@return string
function controller:uid(platform, platformId)
    return ('%s:%s'):format(platform:lower(), Application.hex64_to_dec(platformId))
end

-- Generates hash from unique id
-- remark: sumhexa is already lowercased
---@param platform PlatformType
---@param platformId string
---@return string
---@overload fun(uid: string): string
function controller:hash(platform, platformId)
    local uid = platform
    if platformId then
        uid = self:uid(platform, platformId)
    end
    return self.md5.sumhexa(uid)
end

---@param uid string
---@param level number | nil
---@return CachedInfo
function controller:addAccountCache(uid, level)
    local cache = self.accountCache[uid]
    if cache then
        cache.level = level or cache.level
    else
        cache = {
            level = level or 1,
            hash = self:hash(uid),
        }
    end
    self.accountCache[uid] = cache

    return cache
end

---@param uid string
---@param overrideLevel number | nil
---@return RATINGS | nil, boolean | nil (positive/negative, isCommunityRating)
function controller:getRating(uid, overrideLevel)
    local isCommunity = self:isCommunity()
    ---@type CachedInfo
    local cache
    if isCommunity then
        cache = self:addAccountCache(uid, overrideLevel)
    end

    -- Return local rating if exists
    local rating = langUtils.coalesce(self.localRating, 'accounts', uid, 'rating')
    if rating then
        return rating
    end

    -- If community sync is enabled, fall back to it if local rating is not found
    if isCommunity then
        local communityRating = self.communityRating[cache.hash]
        if communityRating then
            -- show rating with web icon if account has community rating
            return communityRating, true
        end
    end
end

function controller:loadLocalPlayerToCache()
    local backend_interface = Managers.backend.interfaces
    backend_interface.progression:get_entity_type_progression('character')
        :next(function(characters_progression)
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
            self:getRating(self.ownUid, progression.currentLevel)
            self:log(
                'info',
                'Host player loaded into cache',
                'controller:loadLocalPlayerToCache/get_entity_type_progression'
            )
        end)
        :catch(function(error)
            self:log('error', error.description, 'controller:loadLocalPlayerToCache/get_entity_type_progression')
        end)
end

return controller
