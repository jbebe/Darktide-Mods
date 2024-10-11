---@meta

---@alias LogLevel
---| 'error'
---| 'warning'
---| 'info'
---| 'debug'

---@alias PlatformType
---| 'steam'
---| 'xbox'
---| 'psn'
---| 'Unknown'

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

---@alias LocalRatingAccounts table<string, RatingAccount>

---@class LocalRating
---@field version number
---@field accounts LocalRatingAccounts (key: uid)

---@class Teammate
---@field uid string
---@field name string
---@field platform PlatformType
---@field characterName string
---@field characterType CharacterType
---@field characterLevel number

---@class SyncableRatingItem
---@field level number
---@field rating RATINGS

---@class CachedInfo
---@field hash string
---@field level number | nil

---@class RatingsViewContext
---@field controller LovesMeNot
---@field blueprints table
---@field definitions table
---@field settings table

---@alias AccountCache table<string, CachedInfo>
---@alias CommunityRating table<string, RATINGS>
---@alias SyncableRating table<string, SyncableRatingItem>
