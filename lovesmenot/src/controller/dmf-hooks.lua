local gameUtils = modRequire 'lovesmenot/src/utils/game'
local netUtils = modRequire 'lovesmenot/src/utils/network'

---@param controller LovesMeNot
local function init(controller)
    function controller:reinit()
        if self.initialized then
            return
        end

        self.localPlayer = Managers.player:local_player_safe(1)
        if self.localPlayer == nil then
            -- account not yet available, retry later
            return
        end
        self.initialized = true

        local isCloud = self.dmf:get('lovesmenot_settings_cloud_sync')
        if isCloud then
            netUtils.getRatings():next(function(ratings)
                self.rating = ratings
                self.isInMission = gameUtils.isInRealMission()
            end)
        else
            self:loadLocalRating()
            self.isInMission = gameUtils.isInRealMission()
        end
    end

    ---@param initial_call boolean
    function controller.dmf.on_enabled(initial_call)
        -- init mod (again) on reload all mods
        controller:reinit()
    end

    -- Main event handling
    -- We catch global state changes to run functions at specific times,
    -- not neccessarily during playing a level.
    function controller.dmf.on_game_state_changed(status, state_name)
        if state_name == 'StateMainMenu' and status == 'enter' then
            -- Game loaded, user is at the character selector menu
            controller:reinit()
        elseif state_name == 'GameplayStateRun' and status == 'enter' then
            -- Mission started
            if not controller.initialized then
                return
            end

            controller.isInMission = gameUtils.isInRealMission()
        elseif state_name == 'StateGameplay' and status == 'exit' then
            -- Mission ended
            if controller:canRate() then
                controller.isInMission = false
                controller.teammates = {}
                controller:persistLocalRating()
            end
        end
    end
end

return init
