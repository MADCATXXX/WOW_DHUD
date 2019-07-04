Selective Player Buffs has been added. The intention of this feature is to complement, not replace, other player buff mods like CT_BuffMod. To reduce clutter, the Selective Player Buffs only shows short term player buffs. It does not show debuffs, item buffs, or auras without durations like Devotion and Trueshot.

If you feel that you would like these features, ask for them.

-- Caeryn Dryad

Markus wrote:
DHUD is DEAD - There will be no new Version of DHUD
Because of People only change some Textures and do a
Branch of DHUD without my Permisson.
New Versions are only for my Guild from now on.
Thanks to goes to all People that supported DHUD until now.
Everyone who want's can take over this Project.


Links:
DHUD Suggestions: [http://www.wowinterface.com/downloads/info4506-.html#cmnt19537]

Features:
* Based off Drathal's original 0.9b5
* Configuration via /dhud menu
* Configuration via a UI accessable via Minimap Button
* Health and Mana Bars that change colors as they diminish
* Animation Health and Mana Bars
* Shows level, name, class and status of the Target
* Shows level, name, class and status of the Target's Target
* Support for Telo's MobHealth / MobInfo2 / MobHealth2
* 4 Transparency (Alpha) settings for : In Combat / Target Selected / No Target / Player is Regenning
* Customizable display modes for Health, Mana, Target Textbox, Cast Time Textbox and Cast Delay Textbox
* Configurable color settings for Health, Mana, Energy, Rage, tapped mobs and pets
* Mini Pet bars!
* Casting Bar with Casting Time (and Casting Delay!)
* Options to enable or disable any of settings
* Two optional layouts to seperate the bars by Mana/Health or by Target/Player
* Offsets for any of the text frames
* Status indicator icon to show if the mob is elite
* Status indicator icon to show if you're resting
* Status indicator icon to show if you're in combat
* Option to reverse the casting bar
* Support for up to 40 buffs and debuffs
* Support for duration filtered player buffs
* Support for raid icons


Todo:
* Health/Mana of Target of Target
* Show Raid Icons of Target (X, circle, skull, etc)
* Show Class Icon
* Show Target PvP Status
* Show Target PvP Rank
* Druidbar Support
* Target casting bar (many people)
* New Layout - flip player/mana
* Profiles
* Independant frame scaling
* Use a flag for Player Auras so its not called if there is no auras

Known Issues:
* ph_pm_eh_th_tm (Perniciu0s/Curse)

History:
2006.1.9 (v1.4.20003) by Caeryn
* updated the toc to 20003
* selective self buffs is now always fully opaque unless HUD is not shown
* raid icons for your targets will now be visible

2006.12.25 (v1.3c.20000) by Caeryn
* fixed a bug with the reset button
* moved the player buffs from the right side to the left side for layout 2

2006.12.20 (v1.3b.20000) by Caeryn
* fixed a bug that affected people who used layout 2

2006.12.20 (v1.3a.20000) by Caeryn
* fixed a bug that affected first time users

2006.12.19 (v1.3.20000) by Caeryn
* added duration filtered player buffs which can be configured to show only buffs with less than X seconds remaining (limited to 16)
* added text templating for target of target
* added a toggle for target of target (nocomply/curse) 
* fixed a bug where it was not possible to type a negative number into the offsets
* fixed a bug where the text templates were not properly synching between the dropdown box and the templates

2006.12.19 (v1.3.20000) by Caeryn
* added duration filtered player buffs which can be configured to show only buffs with less than X seconds remaining (limited to 16)
* added text templating for target of target
* added a toggle for target of target (nocomply/curse) 
* fixed a bug where it was not possible to type a negative number into the offsets
* fixed a bug where the text templates were not properly synching between the dropdown box and the templates

2006.12.08 (v1.2d.20000) by Caeryn
* fixed a bug with layout2 where it would not display properly
* fixed a bug where unchecking "combat icon" would not remove the combat icon

2006.12.08 (v1.2.20000) by Caeryn
* updated DHUD 0.9b5 for WoW 2.0
* updated the syntax to LUA 5.1
* added Target of Target
* added in-combat icons

2006.12.04 (v1.1.20000a) by Caeryn
* no major bugs reported, making this version live

2006.12.04 (v1.1.20000) by Caeryn
* included DHUD_Options in the packet
* fixed a bug where the countdown timer for the ability to take effect (casttime and casttimedelay) was not
being calculated correct when spell was delayed

2006.12.02 (v1.0.20000) by Caeryn
* updated DHUD for The Burning Crusade WoW 2.0
* updated the syntax to LUA 5.1
* added a new feature - Target of Target
* added a new feature - when targetting a mob the creature type would be shown (beast/undead/humanoid/etc)

2006.04.20 (v0.86)
* fixed DHUD init
* Bliz. Castingbar turned on when DHUD Castingbar is off

2006.04.19 (v0.85)
* fixed Bar/Casting Bug

2006.04.19 (v0.84)
* fixed Scaling over 1.5 (HP/Mana Text wrap problem)
* fixed Minimapbutton Clickable Area
* fixed Barbackground when Dead
* Player / Target rightclick Menu optimized
* added Casting Bar
* added Casting Time / Delay
* added reset Button to Menu
* Option to change Fontcolors
* Option to change Fontoutlines
* Option to Hide Petbars
* Option to Hide Targetbars / Text

2006.04.11 (v0.83)
* DHUD runs now on all WOW Language Versions
* myAddons Support
* Mobhealth2 Bugfix (DHUD now hides Mobhealth2 Targethp when
Blizzard Targetframe is hidden)
* (experimental) DHUD dont show Blizzardframes when they are
Disbaled by DUF, Nymbias Perl Unitframes, Classic Perl Unitframes
* Minimap Button to show Optionsframe
* Support for Telo's Mobhealth

2006.04.08 (v0.82)
* Many new positioning Options.
* New Textures.
* Small Bugfixes.
* Option to Hide NPC.

2006.04.05 (v0.81)
* Slash Command: /dhud bplayer - Blizzard Playerframe on / off
* Slash Command: /dhud btarget - Blizzard Targetframe on / off
* Some Event Optimizing.
* Target Menu with Rightclick on Targetname
* Player Menu with Shift Rightclick on Targetname

2006.04.01 (v0.8)
* Configscreen: /dhud menu

2006.03.20 (v0.72)
* Code Cleanup.
* Small Bugfixes.

2006.01.21 (v0.65)
* Added Support for Playerpets.
* Slash Commands: new Commands for changing x and y offsets.
* Slash Commands: new Commands for changing fontsizes.
* Optimized some Code.
* Updated Textures.

2006.01.18 (v0.61):
* Bugfix: After Login the Playerhealth was Displayed wrong sometimes.

2006.01.18 (v0.6):
* Support for Mobhealth2 / Mobinfo2.
* Slash Command: /dhud regalpha 0 - 1
* Slash Command: /dhud reset
* Slash Command: /dhud showlevel
* Slash Command: /dhud showname
* Slash Command: /dhud showclass
* Slash Command: /dhud showelite
* Slash Command: /dhud playerdisplaymode 1 - 4
* Slash Command: targetdisplaymode 1 - 4
* Baroutlines now hide when Player is Dead.
* New Alphamode regalpha added.
* more Code optimizing.
* Slash Command now give feedback.

2006.01.17 (v0.5):
* HUD leaves Combatmode only when Health and Mana are full.
* Slash Command: /dhud combatalpha 0 - 1
* Slash Command: /dhud nocombatalpha 0 - 1
* Slash Command: /dhud selectalpha 0 - 1

2006.01.16 (v0.41):
* Fixed Bug in Line 260
* 0.5 Scale works now

2006.01.16 (v0.4):
* Rage & Energy are now real Values instead of Percent.
* Slash Command: /dhud scale 0.5-2 to scale entire HUD.

2006.01.16 (v0.31b):
* Removed "0" Level when no Target selected.

2006.01.16 (v0.3b):
* First public Release.