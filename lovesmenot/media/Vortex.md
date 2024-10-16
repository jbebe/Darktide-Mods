# Brief overview

_350 characters or less to give a brief description of the basics_

```
Your voice matters. Mark toxic and good players while you play and share your opinion with the community.
```

# Detailed description

_BBCode format_

```
[size=5]Summary[/size]

Loves Me, Loves Me Not is a lightweight visual modification for Dartkide. It lets you rate people during and between missions for your convenience. This rating is stored locally so you can rate as many people as you want. On the other hand, if you turn on community rating in the mod settings, your ratings are synced to a server where everyone else using the mod can see it, helping the community avoid toxic players and quickly noticing good players.

[size=5]Rating in general[/size]

Rating symbols show up next to player names when you rate them. A rating is bound to an account, not the character. If you managed to catch a toxic player by rating them negative, they will be marked for you as long as you keep the rating file. Ratings are stored in AppData, under [font=Courier New]Darktide/lovesmenot.json [/font]so if you delete it, all your ratings are lost.

[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/rating_in_general.png[/img][/center]
There are 2 types of rating: positive and negative. You either rate someone negative/positive or not, there are no scales or different properties.
Ratings are applied by cycling through them. When a teammate is previously untouched, their first rating will be negative. On your second action, they will be positive. On your third action it removes the rating and the player stays clear again.

[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/toggle_rating.png[/img][/center]
Ratings next to the player name are only visible when you really need it. These screens are the followings:
[list]
[*]Mourningstar
[*]Lobby (where you press Ready)
[*]Mission
[*]Mission end screen
[/list][size=2]
[/size][size=5]Dashboard[/size]

On top of ratings, you get a dashboard. By pressing the hotkey, a fullscreen view comes up with a list of all the players you rated so far. You can view their account information or delete them by clicking on a player. There's also a "Sync now" button that lets you persist your rating immediately. You can open this menu anytime, anywhere, even during missions. So if you fear that your game might crash before your rating is saved to the disk, bring up the dashboard and hit "Sync now".

[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/dashboard.png[/img][/center]
[size=5]Rating in practice
[/size][size=2]
[/size][size=4]Mission[/size]

You see someone rushing forward and die while yelling the most inappropriate things in the microphone. By using the already set hotkeys you press the button that connects to their position on the teammates panel. A small red logo appears next to their name. You caught them. They are now rated as negative. Althought they soon leave the mission, that doesn't scare you because the next time you meet them a glowing red icon will help you decide whether they are reliable or not. When the mission ends, your rating is saved to the disk and you can continue rating people for your convenience.

[size=4]Mourningstar[/size]

When you approach another player, you can inspect their gears. The mod injects another button at the bottom of that popup window that works just like your hotkeys, it cycles through the rating types. As you are not in a mission, this action is immediate, it will be saved to your disk immediately.

[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/mourningstar.png[/img][/center]
[size=4]Social menu[/size]

If someone left before you could rate them, there's still hope! Navigate to Menu/Social/Previous Missions and select the offender. Click on the cycle rating button to set their rating.

[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/social.png[/img][/center]
[size=4]Lobby[/size]

The mod finally becomes useful. Teammates are pouring into the lobby slowly. You suddenly see a red flame icon next to the new player. You rated them negative because of their past actions. Another round with them? No way. Time to leave the lobby.

[size=4]Mission (contd.)[/size]

You are playing with your friends but you miss a 4th teammate. You 3 struggle a [i]little[/i] on Maelstrom X AE A-XII. Someone joins midgame. Behold! A green laurel wreath! They are good but more importantly helpful, share resources and revive everyone. You remember why you rated them positive.

[size=5]Under the hood[/size]

[quote]Hey, that's all nice and dandy but if someone rates me negative, I'll be an outcast among rejects! That's unfair![/quote]
From day one the algorithm for ratings takes into account false single and even group votes. You won't be marked by the red flame icon if someone was mad at you. In order to be rated toxic, you need some ranked players to rate you over time. The keyword is quantity. My way of thinking is that a certain amount of random players around the world can't be wrong all at once.


That's it. That's the mod. Although... there's this tiny extra feature...



[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/separator.png[/img][/center]

[size=5]Community rating[/size]

Community rating is an extra layer on top of the previously introduced (hereby called "local") feature. If you enable community rating, nothing changes in the behavior of local rating but ratings are now synchronized with a server. Simply put, your lovesmenot.json file moves to the cloud and is shared between all mod users.

[size=4]Differences[/size]

[list]
[*]Requires an access token.
[*]When a player has '🌐🔥' next to its name, it means you didn't rate it yet but they have a community rating that says they are negative (as in toxic) players.
[*]When you cycle through the ratings, the neutral version might appear as '🌐🔥' because while you revoked your rating, the player is still rated by the community.
[*]Immediate rating (inspect player, social popup) is slower due to the overhead of reaching the server.
[*]Community ratings are never persisted, they are downloaded when the game starts and refreshed if needed when you press "Sync now" on the dashboard.
[/list]

[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/community_rating.png[/img][/center]
[size=4]Code of conduct[/size]
[size=2]
[/size]"If all you have is a hammer, everything looks like a nail" -- Dartkide player who rates every living thing

A negative player is an intentionally broad expression. A negative player harrasses people in the chat or by voice. Keeps repeating actually toxic behavior, like blowing up every barrel you walk by or eats up all ammo, visibly ignoring your requests. A negative player intentionally harms other players. A negative player disappears and shows up at the end of the map during a Maelstrom mission. They abuse the game in a way that makes it harder for you to play. Those kind of people you rarely encounter but they must be marked somehow because they are a threat to everyone's gaming experience.

A negative player is not a
[list]
[*]level 3 player on Malice
[*]weak player
[*]Ogryn in front of you
[*]Zealot who runs forward and dies
[*]Psyker with a questionable build
[*]Veteran with auto-ping
[*]naked player
[*]player who solves the puzzle quicker than you
[/list]
A positive player is someone who is both kind and skillful. Those that ping enemies, ammo, and revive teammates at the right moment multiple times and clutches multiple times and... and... you get it. Someone who seems to be a god among rejects.

A positive player is not a
[list]
[*]player on (true) level 9999+
[*]very skilled player with no remarkable acts towards the team
[*]player that always tries to help but without situation awareness
[*]guy that showed you how to get some secret
[/list]
To wrap it up, a good attitude towards the Loves Me Not mod is to rate people when you are especially shocked by their behavior. That shock should happen at most once a day, normally.

[size=4]Rules[/size]
Let's talk a little about user behavior. In order to use the community mode of the mod, you have to posess a copy of Dartkide. Darktide is not cheap. In case you rate everyone during every mission, chances are you are getting banned soon and there's no coming back. Another rule is not to force a negative rating on someone by telling your friends to rate the target player. If you are all in a strike team and see someone toxic, that's fair, but if it's organized, chances are you are all banned soon after the stats come in.
As rating cannot be fully objective, those two are the only rules. Just because you rated someone out of spite alone, it won't change the ratings anyway so you're good.

[size=4]Privacy Policy[/size]

The backing database of the community rating service holds data that cannot be used on its own to recover personal information.
The only object that the mod uploads to the server has the following fields:

[list]
[*]mod user's current character level - used for scoring when ratings are created
[*]region (EU / US east / ...) - reserved for future use: return ratings for your current region only
[*]rated player's hashed public platform id - to identify the player during gameplay
[*]rating type (positive/negative)
[*]rated player's current character level - used for scoring when ratings are created (e.g. level 2 player with a few negative ratings is ignored)
[*]mod user's friends' hashed public platform id - used to detect coordinated collective rating
[/list]
The only thing that comes from a sensitive place, your gaming platform, is the hashed publicly available id. The reason I hash all ids is because I don't want to build a list of Darktide players that might be valuable for a malicious party somehow.


[center][img]https://raw.githubusercontent.com/jbebe/Darktide-Mods/refs/heads/master/lovesmenot/media/images/description/separator.png[/img][/center]

[center]Thanks for reading all that. It's important for you but it also helps me when you'll have problems.[/center]
```