---@meta

-- ---@module 'lovemenot/src/constants'

-- ---@class RatingAccountsType
-- ---@field rating RATINGS
-- ---@field name string
-- ---@field platform 'steam' | 'xbox' | 'psn' | 'unknown'
-- ---@field characterName string
-- ---@field characterType 'zealot' | 'veteran' | 'psyker' | 'ogryn'

-- ---@class RatingType
-- ---@field version number
-- ---@field accounts table<string, RatingAccountsType>

-- ---@class LovesMeNot
-- ---@field dmf DmfMod
-- ---@field localPlayer HumanPlayer | nil
-- ---@field initialized boolean
-- ---@field rating RatingType | nil
-- ---@field teammates table
-- ---@field isInMission boolean

---@class RatingsViewContext
---@field controller LovesMeNot
---@field blueprints table
---@field definitions table
---@field settings table
