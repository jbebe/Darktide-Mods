local gameUtils = require "lovesmenot/src/utils/game"

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
        self:loadRating()
        self.isInMission = gameUtils.isInRealMission()
    end

    function controller.dmf.update(dt)
        -- update() is called on every game tick.
        -- We only call initMod if mod is not initialized.
        -- This function might hang the main thread as it loads files from the FS
        -- but it happens during the operator selection menu only.
        controller:reinit()
    end

    -- Main event handling
    -- We catch global state changes to run functions at specific times,
    -- not neccessarily during playing a level.
    function controller.dmf.on_game_state_changed(status, state_name)
        if state_name == "StateMainMenu" and status == "enter" then
            -- Game loaded, user is at the character selector menu
            controller:reinit()
        elseif state_name == "GameplayStateRun" and status == "enter" then
            -- Mission started
            if not controller.initialized then
                return
            end

            controller.isInMission = gameUtils.isInRealMission()
        elseif state_name == "StateGameplay" and status == "exit" then
            -- Mission ended
            if controller:canRate() then
                controller.isInMission = false
                controller.teammates = {}
                controller:persistRating()
            end
        end
    end
end

return init
