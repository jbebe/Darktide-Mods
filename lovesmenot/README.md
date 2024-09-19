
## Development

### Features

* good/meh/bad player detection
  * Query as much data for a user as possible
  * Sadly query is promise based, so we need to do it asynchronously,  
    luckily True Level got us covered with it's own implementation.
  * Parse data and calculate a heuristic for how good or bad of a player they are
    * take into account
      * player left the game
      * (if build/weapon/talent tree can be queried:)
      * player has a <360 base score weapon
      * player level >=30 but talent tree is not finished
      * player doesn't press ready or spams it (LobbyView._sync_votes)
      * player spams taggging for too many times
      * \+ misc. events in game, like revive count, death, accuracy
  * Persistent save that data for eternity
    * It's not really feasible but the scoreboard mod found a solution (save csv as lua)
  * query players when:
    * in lobby (very important, this is where we can escape)
    * in game when a new player joins
* manual player vote
  * (As I see there is no way to click during gameplay so we need to resort to keys.   
    Chat box is also an option but I wouldn't want anyone to be seen doxing people.)
  * During game, press 3 buttons
    * btn1 - press #1 - bad player, #2 good, #3 neutral, #4 nothing
    * etc..
  * After game on the Mourningstar, dialog with 3 users to vote for good/meh/bad

### Server sync

* When you start the mod, you don't have anything
* At the main menu, if it's a fresh start (no json) and server sync is enabled, sync all data and persist it in the json
  * If sync is not enabled, just work with the current setup that we have on the main branch
  * If sync is enabled, after every game start, sync runs at the beginning, keeping the local db fresh
  * You can perform a manual sync from the mod menu (is there a button to do so?)
* If you add a new vote / change the current vote, it's stored with the synced data but the id is also stored in a 'new id table'
  * if that 'new id table' has any items in it, sync it to the server.
  * A new toxic or good player is rarely added so it's not a big deal if we have to sync multiple entries at once. We can just use the batch download and upload.
* If the update was successful (not error callback) we clear the 'new id table' and that's it. We will sync again if needed.
* What about collision? Oh oh. I don't know.

### Networking

| Reef | (AWS) Region |
| - | -: |
| afr-south | aws-af-south-1 |
| ap-central | aws-ap-southeast-1 |
| ap-north | aws-ap-northeast-1 <br> aws-ap-northeast-2 |
| ap-south | aws-ap-southeast-2 |
| eu | aws-eu-central-1<br>aws-eu-north-1<br>aws-eu-west-1<br>aws-eu-west-2 |
| hk | aws-ap-east-1 |
| mei | aws-ap-south-1<br>aws-me-south-1 |
| sa | aws-sa-east-1 |
| us-east | aws-ca-central-1<br>aws-us-east-1<br>aws-us-east-2 |
| us-west | aws-us-west-1<br>aws-us-west-2 |

### Dev env setup

Link mod folder to darktide mod folder:

* set env var DARKTIDE_MODS_PATH to the darktide mod folder
* set env var DARKTIDE_PROJECTS_PATH to the darktide projects folder, the parent of this folder
* run `mklink /d "%DARKTIDE_MODS_PATH%\lovesmenot" "%DARKTIDE_PROJECTS_PATH%\lovesmenot"` (with elevated privileges, if needed)

(of course you should also add your mod name to `mod_load_order.txt`)

### Useful stuff

#### [Sequence diagram for sync/local behavior](https://sequencediagram.org/index.html#initialData=C4S2BsFMAIFkHsAm1EENiugM3PA7gFAEAOqATqAMYikB2wcqItsktArieVTavXEgAiqAM4ALAEbxyiLhRDU6DADLwJEgJ5yeS6IPZlmAcwDiqALaRtC3vwCitRGctFa8YDHgA3SGUbNWDgAuaGcYMVFoEQwKSFk5aAAxEDJo6FAXNw9ob19-FjZ2EIA5eBziX3QQeFoCYDEySFRkAGUNWkocrCwCWCYCjgBaAD4+gMKQsiraIwBeXGaAJWmjAAoASjqGptb2zpre-sD2EdWAVnWxgaLoKdAZ2aNIYGX7oxENgjZ40j82jq6PSynh8fgQiGE4ikMhCAAVGiIRNAANaQDTpMoVVIgNJoDBbRrNaD-fa1YE5UECCGiSTSMiIOEIpGo9HAMrsYgLZAAMiiey+jlc7hBeVU6g0jMgIjYDDuxgAOrQJKI4jlaFFIOAsAA6OUzIi-Yl7QEEcm5Pz6QwzMIhaUMaVa3UrAk7I0Ag5mymW4w2jX2zU6vVGaC8h062iQPCvYwCn7kN37bqm4UUvIOJwWSBw3wiHH+x1Bl1Eklq5PZc3QdO+kth7URqMrDEasigxW1+vRmbQWbQADeAF9Y0A)

#### REST api

Example:
```lua
if not Managers.backend:authenticated() then
  Log.error('Cannot initiate api call if not authenticated to game backend')
end
Managers.backend:url_request(url, {
		require_auth = true, -- this must be true always!
    method = "POST",
    body = {
      placeholder = "",
    },
    headers = {
      headerName = headerData,
  }
	}):next(
    function(responseBody){ 
      processData(responseBody)
    }, 
    function(errorObject){
      local errorMessage = type(errorObject) == "table" and table.tostring(errorObject, 3) or errorObject
      Log.warning("<classname>", "Failed to <...> for url '%s' with error: %s", url, errorMessage)
    })
```

#### Player infos

* player:profile()
  * talent_points
  * current_level
  * unique_id (7826ea4887f78407:1:1)
* player._account_id
* player._unique_id
* _telemetry_subject
  * account_id (04e687c2-ba13-414b-9b25-6e68c7d762a2)
  * character_id (3cc1cf49-8b7a-4fe7-bc03-7c65ad899962)
  * bot (true/false)

#### Text formatting

* `{#color(216,229,207,120)}colorized alpha text{#reset()}`
* `{#color(216,229,207)}colorized text{#reset()}`
* `{#size(30)}text with font size 30{#reset()}`
* `{#under(true)}underline this text{#under(false)}`
* `{#strike(true)}strike through text{#strike(false)}`

#### Snippets

Check if we are on the training map / hub / etc.

```lua
local host_type = Managers.connection:host_type()
local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
local is_in_hub = host_type == "hub_server" or game_mode_name == "hub"
local is_in_training_grounds = game_mode_name == "shooting_range" or game_mode_name == "training_grounds"
```

#### Icons

* \ue000 logo
* \ue001 check
* \ue002 locked
* \ue003 unlocked
* \ue004 weird arrow down with skull
* \ue005 user
* \ue006 chevron 2
* \ue007 timer
* \ue008 triangle up
* \ue009 triangle right
* \ue00a triangle down
* \ue00b triangle left
* \ue00c logo
* \ue00d logo
* \ue00e logo
* \ue010 0 (7 segment display)
* \ue011 1
* \ue012 2
* \ue013 3 
* \ue014 4
* \ue015 5
* \ue016 6
* \ue017 7
* \ue018 8
* \ue019 9
* \ue01a veteran
* \ue01b zealot
* \ue01c psyker
* \ue01d ogryn
* \ue01e skull with crown
* \ue01f skull
* \ue020 chevron 3
* \ue021 flame
* \ue022 skull aura
* \ue023 veteran
* \ue024 zealot
* \ue025 psyker
* \ue026 ogryn
* \ue027 knife
* \ue028 lightning
* \ue029 check seal
* \ue031 settings
* \ue032 money
* \ue033 medal
* \ue040 dogtag
* \ue041 ?
* \ue042 laurel wreath
* \ue044 profile
* \ue045 skull
* \ue046 block
* \ue063 ?
* \ue064 left click
* \ue065 right click
* \ue066 middle click
* \ue067 scroll
* \ue068 mouse 4
* \ue069 mouse 5
* \ue06a keyboard
* \ue06b console
* \ue06c steam
* \ue06d xbox
* \ue06e scroll down
* \ue06f scroll up
* \ue0c7 web
* \ue0c8 A
* \ue0c9 B
* \ue0ca X 
* \ue0cb Y
* \ue0cc ?
* \ue0cd ?
* \ue0ce ?
* \ue0cf ?
* \ue0d0 LB
* \ue0d1 RB
* \ue0d2 LT
* \ue0d3 RT
* \ue0d4 ?
* \ue0d5 ?
* \ue0d6 empty wasd
* \ue0d7 W wasd
* \ue0d8 D wasd
* \ue0d9 S wasd
* \ue0da A wasd
* \ue0db WS wasd
* \ue0dc AD wasd
* \ue0dd LS
* \ue0de RS
* \ue0df LS
* \ue0e0 RS
* \ue0e1 ...
* \ue0e2 ...

#### Game states

```
-- start the game
StateGame (status: enter)
StateTitle (status: exit)
StateMainMenu (enter -> exit)

-- load a new world (hub)
StateLoading (enter -> exit)
GameplayInitStepFrameRate (status: enter)
GameplayStateInit (status: enter)
StateGameplay (status: enter)
GameplayInitStepFrameRate (status: exit)
GameplayInitStepOutOfBounds (enter -> exit)
GameplayInitStepNavWorld (enter -> exit)
GameplayInitStepDebug (enter -> exit)
GameplayInitStepFreeFlight (enter -> exit)
GameplayInitStepGameSession (enter -> exit)
GameplayInitStepGameMode (enter -> exit)
GameplayInitStepMission (enter -> exit)
GameplayInitStepBoneLod (enter -> exit)
GameplayInitStepNavigation (enter -> exit)
GameplayInitStepExtensions (enter -> exit)
GameplayInitStepManagers (enter -> exit)
GameplayInitStepNvidiaAiAgent (enter -> exit)
GameplayInitStepExtensionUnits (enter -> exit)
GameplayInitStepNetworkEvents (enter -> exit)
GameplayInitStepTimer (enter -> exit)
GameplayInitStepNavWorldVolume (enter -> exit)
GameplayInitStepNavSpawnPoints (enter -> exit)
GameplayInitStepMainPathOcclusion (enter -> exit)
GameplayInitStepFinalizeNavigation (enter -> exit)
GameplayInitStepPlayerEnterGame (enter -> exit)
GameplayInitStepMusic (enter -> exit)
GameplayInitStepVoiceOver (enter -> exit)
GameplayInitStepNetworkStory (enter -> exit)
GameplayInitLevelSpawned (enter -> exit)
GameplayInitStepFinalizeExtensions (enter -> exit)
GameplayInitStepPacing (enter -> exit)
GameplayInitStepTerrorEvent (enter -> exit)
GameplayInitStepMutator (enter -> exit)
GameplayInitStepFinalizeDebug (enter -> exit)
GameplayInitStepBreedTester (enter -> exit)
GameplayInitStepMissionServer (enter -> exit)
GameplayInitStepStateLastChecks (enter -> exit)
GameplayInitStepStateWaitForGroup (enter -> exit)
GameplayInitStepStateLast (status: enter)
GameplayStateInit (status: exit)
GameplayStateRun (status: enter)
StateGameplay (status: exit)
GameplayStateRun (status: exit)

-- load a new world (psykhanium)
StateLoading (enter -> exit)
GameplayInitStepFrameRate (status: enter)
GameplayStateInit (status: enter)
StateGameplay (status: enter)
GameplayInitStepFrameRate (status: exit)
GameplayInitStepOutOfBounds (enter -> exit)
GameplayInitStepNavWorld (enter -> exit)
GameplayInitStepDebug (enter -> exit)
GameplayInitStepFreeFlight (enter -> exit)
GameplayInitStepGameSession (enter -> exit)
GameplayInitStepGameMode (enter -> exit)
GameplayInitStepMission (enter -> exit)
GameplayInitStepBoneLod (enter -> exit)
GameplayInitStepNavigation (enter -> exit)
GameplayInitStepExtensions (enter -> exit)
GameplayInitStepManagers (enter -> exit)
GameplayInitStepNvidiaAiAgent (enter -> exit)
GameplayInitStepExtensionUnits (enter -> exit)
GameplayInitStepNetworkEvents (enter -> exit)
GameplayInitStepTimer (enter -> exit)
GameplayInitStepNavWorldVolume (enter -> exit)
GameplayInitStepNavSpawnPoints (enter -> exit)
GameplayInitStepMainPathOcclusion (enter -> exit)
GameplayInitStepFinalizeNavigation (enter -> exit)
GameplayInitStepPlayerEnterGame (enter -> exit)
GameplayInitStepMusic (enter -> exit)
GameplayInitStepVoiceOver (enter -> exit)
GameplayInitStepNetworkStory (enter -> exit)
GameplayInitLevelSpawned (enter -> exit)
GameplayInitStepFinalizeExtensions (enter -> exit)
GameplayInitStepPacing (enter -> exit)
GameplayInitStepTerrorEvent (enter -> exit)
GameplayInitStepMutator (enter -> exit)
GameplayInitStepFinalizeDebug (enter -> exit)
GameplayInitStepBreedTester (enter -> exit)
GameplayInitStepMissionServer (enter -> exit)
GameplayInitStepStateLastChecks (enter -> exit)
GameplayInitStepStateWaitForGroup (enter -> exit)
GameplayInitStepStateLast (status: enter)
GameplayStateInit (status: exit)
GameplayStateRun (status: enter)
StateGameplay (status: exit)
GameplayStateRun (status: exit)

-- load a new world (hub)
StateLoading (enter -> exit)
GameplayInitStepFrameRate (status: enter)
GameplayStateInit (status: enter)
StateGameplay (status: enter)
GameplayInitStepFrameRate (status: exit)
GameplayInitStepOutOfBounds (enter -> exit)
GameplayInitStepNavWorld (enter -> exit)
GameplayInitStepDebug (enter -> exit)
GameplayInitStepFreeFlight (enter -> exit)
GameplayInitStepGameSession (enter -> exit)
GameplayInitStepGameMode (enter -> exit)
GameplayInitStepMission (enter -> exit)
GameplayInitStepBoneLod (enter -> exit)
GameplayInitStepNavigation (enter -> exit)
GameplayInitStepExtensions (enter -> exit)
GameplayInitStepManagers (enter -> exit)
GameplayInitStepNvidiaAiAgent (enter -> exit)
GameplayInitStepExtensionUnits (enter -> exit)
GameplayInitStepNetworkEvents (enter -> exit)
GameplayInitStepTimer (enter -> exit)
GameplayInitStepNavWorldVolume (enter -> exit)
GameplayInitStepNavSpawnPoints (enter -> exit)
GameplayInitStepMainPathOcclusion (enter -> exit)
GameplayInitStepFinalizeNavigation (enter -> exit)
GameplayInitStepPlayerEnterGame (enter -> exit)
GameplayInitStepMusic (enter -> exit)
GameplayInitStepVoiceOver (enter -> exit)
GameplayInitStepNetworkStory (enter -> exit)
GameplayInitLevelSpawned (enter -> exit)
GameplayInitStepFinalizeExtensions (enter -> exit)
GameplayInitStepPacing (enter -> exit)
GameplayInitStepTerrorEvent (enter -> exit)
GameplayInitStepMutator (enter -> exit)
GameplayInitStepFinalizeDebug (enter -> exit)
GameplayInitStepBreedTester (enter -> exit)
GameplayInitStepMissionServer (enter -> exit)
GameplayInitStepStateLastChecks (enter -> exit)
GameplayInitStepStateWaitForGroup (enter -> exit)
GameplayInitStepStateLast (status: enter)
GameplayStateInit (status: exit)
GameplayStateRun (status: enter)
StateGameplay (status: exit)
GameplayStateRun (status: exit)

-- exit to main menu
StateExitToMainMenu (enter -> exit)
StateMainMenu (status: enter)

-- exit game
StateGame (status: exit)
StateMainMenu (status: exit)
```