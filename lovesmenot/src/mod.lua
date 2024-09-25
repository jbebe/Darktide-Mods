-- modRequire will now act like require in vscode and type inference can work
-- (check settings.json/Lua.runtime.special)
local mod = get_mod('lovesmenot')
rawset(_G, 'modRequire', function(modPath) return mod:io_dofile(modPath) end)

-- controller props
local controller = modRequire 'lovesmenot/src/controller/controller'

-- controller methods
modRequire 'lovesmenot/src/controller/persistence' (controller)
modRequire 'lovesmenot/src/controller/dmf-hooks' (controller)
modRequire 'lovesmenot/src/controller/cloud' (controller)
modRequire 'lovesmenot/src/controller/hotkeys' (controller)
modRequire 'lovesmenot/src/controller/view-ratings' (controller)
modRequire 'lovesmenot/src/controller/view-inspect' (controller)
modRequire 'lovesmenot/src/controller/commands' (controller)
modRequire 'lovesmenot/src/controller/format-name' (controller)

-- hooks
modRequire 'lovesmenot/src/controller/hooks/game-end-screen' (controller)
modRequire 'lovesmenot/src/controller/hooks/player-joins-lobby' (controller)
modRequire 'lovesmenot/src/controller/hooks/player-joins-midgame' (controller)
modRequire 'lovesmenot/src/controller/hooks/player-nameplate' (controller)

controller:registerRatingsView()
