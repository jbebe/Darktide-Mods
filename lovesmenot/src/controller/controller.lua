---@module 'lovemenot/src/types/dmf-types'
---@module 'lovemenot/src/types/darktide-types'
---@module 'lovemenot/src/constants'

---@type DmfMod
local dmf = get_mod("lovesmenot")

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

---@class RatingAccountsType
---@field rating RATINGS
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType

---@class RatingType
---@field version number
---@field accounts table<string, RatingAccountsType>

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
}

function controller:canRate()
    return self.initialized and self.isInMission
end

return controller
