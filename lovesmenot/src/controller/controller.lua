---@module 'lovemenot/src/types/dmf-types'
---@module 'lovemenot/src/types/darktide-types'
---@module 'lovemenot/src/constants'

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

---@class RatingAccountType
---@field rating RATINGS
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType
---@field creationDate string

---@class RatingType
---@field version number
---@field accounts table<string, RatingAccountType>

---@class TeammateType
---@field accountId string
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType

---@class LovesMeNot
---@field dmf DmfMod | table<string, function>
---@field localPlayer HumanPlayer | nil
---@field initialized boolean
---@field rating RatingType | nil
---@field teammates table
---@field isInMission boolean
---@field debugging boolean
---@field loadRating function
---@field persistRating function
---@field reinit function
---@field registerRatingsView function
---@field openRatings function
---@field updateRating fun(self: LovesMeNot, teammate: TeammateType)
---@field formatPlayerName fun(self: LovesMeNot, oldText: string, accountId: string): string, boolean
---@field rateTeammate fun(self: LovesMeNot, teammateIndex: number)
local controller = {
    dmf = dmf,
    initialized = false,
    isInMission = false,
    localPlayer = nil,
    teammates = {},
    rating = nil,
    debugging = false,
    timers = timers
}

function controller:canRate()
    return self.initialized and self.isInMission
end

return controller
