local mod = get_mod("lovesmenot")

local function initMod()
    mod.initialized = true
    mod.localPlayer = Managers.player:local_player_safe(1)
    mod:load_rating()
    mod.isInMission = mod:_isInMission()
end

mod.update = function(dt)
    if mod.initialized then
        return
    end

    -- update() is called on every game tick.
    -- We only call initMod if mod is not initialized.
    -- This function might hang the main thread as it loads files from the FS
    -- but it happens during the operator selection menu only.
    initMod()
end

-- Main event handling
-- We catch global state changes to run functions at specific times,
-- not neccessarily during playing a level.
mod.on_game_state_changed = function(self, status, state_name)
    if state_name == "StateMainMenu" and status == "enter" then
        -- Game loaded, user is at the character selector menu
        initMod()
    elseif state_name == "GameplayStateRun" and status == "enter" then
        -- Mission started
        if not mod.initialized then
            return
        end

        mod.isInMission = self:_isInMission()
    elseif state_name == "StateGameplay" and status == "exit" then
        -- Mission ended
        if mod.initialized and mod.isInMission then
            mod.isInMission = false
            mod.teammates = nil
            self:persist_rating()
        end
    end
end
