-- controller props
local controller = require 'lovesmenot/src/controller/controller'

-- controller methods
require 'lovesmenot/src/controller/persistence' (controller)
require 'lovesmenot/src/controller/dmf-hooks' (controller)
require 'lovesmenot/src/controller/hotkeys' (controller)
require 'lovesmenot/src/controller/view-ratings' (controller)
require 'lovesmenot/src/controller/view-inspect' (controller)
require 'lovesmenot/src/controller/commands' (controller)
require 'lovesmenot/src/controller/format-name' (controller)

-- hooks
require 'lovesmenot/src/controller/hooks/game-end-screen' (controller)
require 'lovesmenot/src/controller/hooks/player-joins-lobby' (controller)
require 'lovesmenot/src/controller/hooks/player-joins-midgame' (controller)
require 'lovesmenot/src/controller/hooks/player-nameplate' (controller)

controller:registerRatingsView()
