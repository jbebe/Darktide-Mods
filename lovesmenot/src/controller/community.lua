local BackendUtilities = require('scripts/foundation/managers/backend/utilities/backend_utilities')

local gameUtils = modRequire 'lovesmenot/src/utils/game'
local netUtils = modRequire 'lovesmenot/src/utils/network'
local langUtils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    function controller:downloadCommunityRating()
        local accessToken = controller:getAccessToken()
        if accessToken == nil then
            return
        end
        netUtils.getRatings(accessToken):next(function(ratings)
            self.communityRating = ratings
            local selfRating = ratings[self.localPlayer._account_id]
            if selfRating ~= nil and not self:hideOwnRating() then
                gameUtils.directNotification(self.dmf:localize('lovesmenot_ingame_self_status', selfRating), false)
            end
        end):catch(function(error)
            -- TODO: move to localization
            gameUtils.directNotification('Community server is unreachable. Reload game to retry.', true)
            -- TODO: change every disable mod to initialized = false
            controller.initialized = false
        end)
    end

    function controller:uploadCommunityRating()
        local localPlayer = controller.localPlayer
        if not localPlayer then
            -- player is not loaded yet
            return false
        end
        local accessToken = controller:getAccessToken()
        if accessToken == nil then
            -- access token is not set yet
            return false
        end
        if langUtils.isEmpty(self.syncableRating) then
            -- nothing to sync to cloud
            return false
        end

        ---@type table<string, TargetRequest>
        local targets = {}
        for _, item in pairs(self.syncableRating) do
            targets[item.idHash] = {
                type = item.rating,
                characterLevel = item.level,
            }
        end

        local sourceCache = self.accountCache[self.localPlayer._account_id]
        ---@type RatingRequest
        local request = {
            characterLevel = sourceCache.level,
            reef = BackendUtilities.prefered_mission_region,
            accounts = targets,
            friends = self.localPlayerFriends,
        }
        netUtils.updateRatings(accessToken, request):next(function()
            self.syncableRating = {}
        end)

        return true
    end
end

return init
