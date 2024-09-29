local ProfileUtils = require 'scripts/utilities/profile_utils'

---@param controller LovesMeNot
local function init(controller)
    -- Player joins the morningstar and data from players on the ship are slowly coming in
    controller.dmf:hook_safe(CLASS.PresenceEntryImmaterium, '_process_character_profile_convert',
        function(self, new_entry)
            local accountId = new_entry.account_id
            local cache = controller.accountCache[accountId]

            -- Cache already loaded for player
            if cache ~= nil then return end

            local key_values = new_entry.key_values
            local character_profile = key_values and key_values.character_profile
            if character_profile then
                local backend_profile_data = ProfileUtils.process_backend_body(cjson.decode(character_profile.value))
                ---@type CharacterProgression
                local backend_progression = backend_profile_data.progression
                cache = controller:addAccountCache(accountId, backend_progression.currentXp)
                controller.accountCache[accountId] = cache
            end
        end)
end

return init
