local BackendUtilities = require('scripts/foundation/managers/backend/utilities/backend_utilities')

local gameUtils = modRequire 'lovesmenot/src/utils/game'
local netUtils = modRequire 'lovesmenot/src/utils/network'
local langUtils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    function controller:downloadCommunityRatingAsync()
        local accessToken = controller:getAccessToken() --[[ @as string ]]

        ---@param ratings CommunityRating
        return netUtils.getRatingsAsync(accessToken):next(function(ratings)
            self.communityRating = ratings
            local selfRating = ratings[self.ownHash]
            if selfRating ~= nil and not self:hideOwnRating() then
                self:log('info', 'User received the rating of themself', 'controller:downloadCommunityRatingAsync')
                gameUtils.directNotification(self.dmf:localize('lovesmenot_ingame_self_status', selfRating), false)
            end
        end):catch(function(error)
            self:log('error', error, 'controller:downloadCommunityRatingAsync/getRatingsAsync')
            gameUtils.directNotification(
                controller.dmf:localize('lovesmenot_ingame_community_error'),
                true
            )
            controller.initialized = false
        end)
    end

    function controller:uploadCommunityRatingAsync()
        if langUtils.isEmpty(self.syncableRating) then
            -- nothing to sync to cloud
            ---@cast Promise Promise
            return Promise.resolved(nil)
        end

        ---@type table<string, TargetRequest>
        local targets = {}
        for hash, item in pairs(self.syncableRating) do
            targets[hash] = {
                type = item.rating,
                characterLevel = item.level,
            }
        end

        local sourceCache = self.accountCache[self.ownHash]
        ---@type RatingRequest
        local request = {
            characterLevel = sourceCache.level,
            reef = BackendUtilities.prefered_mission_region,
            accounts = targets,
            friends = self.localPlayerFriends,
        }
        local accessToken = controller:getAccessToken() --[[ @as string ]]

        return netUtils.updateRatingsAsync(accessToken, request):next(function()
            self.syncableRating = {}
        end):catch(function(error)
            self:log('error', error, 'controller:uploadCommunityRatingAsync/updateRatingsAsync')
            gameUtils.directNotification(
                controller.dmf:localize('lovesmenot_ingame_community_error'),
                true
            )
            controller.initialized = false
        end)
    end
end

return init
