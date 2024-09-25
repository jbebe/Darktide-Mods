local BackendUtilities = require('scripts/foundation/managers/backend/utilities/backend_utilities')

local gameUtils = modRequire 'lovesmenot/src/utils/game'
local netUtils = modRequire 'lovesmenot/src/utils/network'

---@param controller LovesMeNot
local function init(controller)
    function controller:loadRemoteRating()
        netUtils.getRatings():next(function(ratings)
            self.remoteRating = ratings
            self.isInMission = gameUtils.isInRealMission()

            local selfRating = ratings[self.localPlayer._account_id]
            if selfRating ~= nil and self.dmf:get('lovesmenot_settings_cloud_sync_hide_own_rating') then
                gameUtils.directNotification(self.dmf:localize('lovesmenot_ingame_self_status', selfRating), false)
            end
        end)
    end

    function controller:syncRemoteRating()
        local localPlayer = controller.localPlayer
        if not localPlayer then
            -- player is not loaded yet
            return
        end
        if #self.syncableRating == 0 then
            -- nothing to sync to cloud
            return
        end

        ---@type table<string, TargetRequest>
        local targets = {}
        for _, item in pairs(self.syncableRating) do
            targets[item.idHash] = {
                type = item.rating,
                targetXp = item.characterXp,
            }
        end

        local sourceCache = self.accountCache[self.localPlayer._account_id]
        ---@type RatingRequest
        local request = {
            sourceHash = sourceCache.idHash,
            sourceXp = sourceCache.characterXp,
            sourceReef = BackendUtilities.prefered_mission_region,
            targets = targets
        }
        netUtils.updateRatings(request):next(function()
            self.syncableRating = {}
        end)
    end
end

return init
