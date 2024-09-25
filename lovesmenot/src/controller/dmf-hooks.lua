local gameUtils = modRequire 'lovesmenot/src/utils/game'

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

        if self:isCloud() then
            self:loadRemoteRating()
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
                if controller:isCloud() then
                    controller:syncRemoteRating()
                else
                    controller:persistLocalRating()
                end
            end
        end
    end
end

return init
