local gameUtils = modRequire 'lovesmenot/src/utils/game'
local netUtils = modRequire 'lovesmenot/src/utils/network'
local langUtils = modRequire 'lovesmenot/src/utils/language'
local constants = modRequire 'lovesmenot/src/constants'

---@param controller LovesMeNot
local function init(controller)
    function controller:downloadCommunityRatingAsync()
        local accessToken = self:getAccessToken() --[[ @as string ]]

        ---@param ratings CommunityRating
        return netUtils.getRatingsAsync(accessToken):next(function(ratings)
            self.communityRating = ratings
            local selfRating = ratings[self.ownHash]
            if selfRating ~= nil and not self:hideOwnRating() then
                self:log('info', 'User received the rating of themself', 'controller:downloadCommunityRatingAsync')
                gameUtils.directNotification(self.dmf:localize('lovesmenot_ingame_self_status', selfRating), false)
            end
        end):catch(function(error)
            self:log(
                'error',
                error and error.description or 'Network error',
                'controller:downloadCommunityRatingAsync/getRatingsAsync'
            )
            gameUtils.directNotification(
                self.dmf:localize('lovesmenot_ingame_community_error'),
                true,
                constants.NOTIFICATION_DELAY_LONG
            )
            self.initialized = false
        end)
    end

    function controller:uploadCommunityRatingAsync()
        if langUtils.isEmpty(self.syncableRating) then
            -- nothing to sync to cloud
            ---@cast Promise Promise
            return Promise.resolved(nil)
        end

        ---@type table<string, TargetRequest>
        local deletes = nil
        local updates = nil
        for hash, item in pairs(self.syncableRating) do
            if item.delete == true then
                deletes = deletes or {}
                table.insert(deletes, hash)
            else
                updates = updates or {}
                updates[hash] = {
                    type = item.rating,
                    characterLevel = item.level,
                }
            end
        end

        local sourceCache = self.accountCache[self.ownUid]
        ---@type RatingRequest
        local request = {
            characterLevel = sourceCache.level,
            reef = self.reef,
            updates = updates,
            deletes = deletes,
            friends = self.localPlayerFriends,
        }
        local accessToken = self:getAccessToken() --[[ @as string ]]

        return netUtils.updateRatingsAsync(accessToken, request):next(function()
            local syncedRatingCount = #langUtils.keys(self.syncableRating)
            self:log(
                'info',
                ('Successfully uploaded %d vote(s)'):format(syncedRatingCount),
                'controller:uploadCommunityRatingAsync/updateRatingsAsync'
            )
            gameUtils.directNotification(
                self.dmf:localize('lovesmenot_ingame_community_sync_success', syncedRatingCount)
            )
            self.syncableRating = {}
        end):catch(function(error)
            self:log('error', error.description, 'controller:uploadCommunityRatingAsync/updateRatingsAsync')
            gameUtils.directNotification(
                self.dmf:localize('lovesmenot_ingame_community_error'),
                true,
                constants.NOTIFICATION_DELAY_LONG
            )
            self.initialized = false
        end)
    end
end

return init
