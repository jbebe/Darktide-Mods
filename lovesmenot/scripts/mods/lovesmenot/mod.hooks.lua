local mod = get_mod("lovesmenot")

function mod.initMod(self)
    if self.initialized then return end

    self.initialized = true
    self.localPlayer = Managers.player:local_player_safe(1)
    self:loadRating()
    self.isInMission = mod:_isInMission()
end

function mod.update(dt)
    -- update() is called on every game tick.
    -- We only call initMod if mod is not initialized.
    -- This function might hang the main thread as it loads files from the FS
    -- but it happens during the operator selection menu only.
    mod:initMod()
end

-- Main event handling
-- We catch global state changes to run functions at specific times,
-- not neccessarily during playing a level.
function mod.on_game_state_changed(status, state_name)
    if state_name == "StateMainMenu" and status == "enter" then
        -- Game loaded, user is at the character selector menu
        mod:initMod()
    elseif state_name == "GameplayStateRun" and status == "enter" then
        -- Mission started
        if not mod.initialized then
            return
        end

        mod.isInMission = mod:_isInMission()
    elseif state_name == "StateGameplay" and status == "exit" then
        -- Mission ended
        if mod.initialized and mod.isInMission then
            mod.isInMission = false
            mod.teammates = {}
            mod:persistRating()
        end
    end
end
