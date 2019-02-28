# CHANGELOG

## Version 80100.06

- Fixed an issue where multiple transmog toasts were shown for different sources of the same  
  appearance. It's mainly occurring when turning in the weekly conquest quest.

## Version 80100.05

- Fixed an issue where world quest toasts wouldn't show the rewards;
- Tweaked achievement toasts. Added tooltips, guild achievements' toasts will now use "Guild  
  Achievement Earned" as their title;
- Updated German translation. Translated by Merathilis@Curse;
- Updated Traditional Chinese translation. Translated by BNSSNB@Curse;
- Updated embeds.

## Version 80100.04

- Added "SetSkin" and "ResetSkin" callbacks. Use these if you hooked my ApplySkin method to modify toasts'  
  appearance since ApplySkin no longer exists. Callbacks use CallbackHandler-1.0, so something like  
  `ls_Toasts[1].RegisterCallback({}, "SetSkin", function(callbackName, toast) end)` should do the trick;
- Updated Traditional Chinese translation. Translated by BNSSNB@Curse;
- Misc performance and memory optimisations.

## Version 80100.03

- Added support for multiple toast anchors. Each anchor has its own growth, scale, and other  
  settings;
- Added options to adjust toast growth offsets.

## Version 80100.02

- Improved compatibility with addons that modify chat messages which are used by common loot and  
  currency toasts.

## Version 80100.01

- Added 8.1.0 support;
- Slightly reorganised in-game config;
- Fixed common loot toasts. Items created via professions and scrapping should be handled  
  correctly once again.

## Version 80000.06

- Added "Default (Legacy)" and "ElvUI (Legacy)" skins that use old texture backgrounds;
- Updated Simplified Chinese translation. Translated by dxlmike@Curse.

## Version 80000.05

- Updated the default background texture. Retired all other backgrounds, but I'll eventually  
  redraw some of them in higher resolution;
- Updated included ElvUI skins;
- Updated Korean translation. Translated by next96@Curse.

## Version 80000.04

- Reduced anchor frame's offsets to 4px. Now you can move toasts closer to the screen edge;
- Updated Simplified Chinese translation. Translated by y368413@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse;
- Updated embeds.

## Version 80000.03

- Fixed an issue where the addon would try to show a toast for an item whose data wasn't available.

## Version 80000.02

- Updated Spanish translations. Translated by Gotzon@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse;
- Updated embeds.

## Version 80000.01

- Added 8.0.1 support;
- Added War Effort (BfA garrison) toasts;
- Added partial Latin American Spanish translation. Copied from Spanish;
- Updated German translation. Translated by staratnight@Curse;
- Updated French translation. Translated by Daniel8513@Curse;
- Updated embeds.

## Version 70300.10

- Updated Traditional Chinese translation.

## Version 70300.09

- Reworked slots for additional rewards;
- Updated Korean translation. Translated by next96@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse.

## Version 70300.08

- Fixed libs' loading order.

## Version 70300.07

- Reworked skin engine. Added new toast and icon border textures. Added two basic ElvUI-like skins;
- Reworked sound controls. Now each toast group has its own SFX toggle;
- Embedded LibSharedMedia. Added font and font size controls;
- Added buttons for 1px adjustment to toast anchor frame;
- Added rarity threshold control for border and text colouring;
- Fixed issue which caused loot toast duplicates to appear;
- Updated Russian translation.

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 70300.06

- Improved compatibility with other addons that override UI elements' alpha, e.g., Immersion;
- Increased max fade-out delay to 10 seconds;
- Fixed "Handle Left Click" option for transmog toasts;
- Updated Korean translation. Translated by next96@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse.

## Version 70300.05

- Fixed DND option. Previously it's disabling toast group entirely;
- Re-added click handler to collection toasts;
- Locked collection and transmog toasts' left click handling behind config option. Both may cause UI errors in combat if enabled, but people like being able to click them regardless;
- Updated German translation. Translated by pas06@Curse.

## Version 70300.04

- Removed click handler from collection toasts. It taints Blizz code too much;
- Updated Korean translation. Translated by yuk6196@Curse;
- Updated Simplified Chinese translation. Translated by y368413@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse.

## Version 70300.03

- Fixed errors caused by toasts' click handlers. Sadly, as of now you won't be able to open UI panels via clicking related toasts while in combat;
- Fixed taint issue caused by toy toast;
- Added French translation. Translated by cyberlinkfr@Curse;
- Updated German translation. Translated by pas06@Curse;

NOTE: I reorganised folder structure, so you'll have to restart WoW client to make things work after the update.

## Version 70300.02

- Fixed toast fade out animation bug.

## Version 70300.01

- Added options to control border and icon border colouring;
- Added new toast type: Collection. Includes toasts for mounts, pets and toys;
- Fixed item count text. If item count it 1, it's hidden;
- Updated German translation. Translated by pas06@Curse;
- Updated Korean translation. Translated by yuk6196@Curse;
- Updated Russian translation;
- Updated Simplified Chinese translation. Translated by y368413@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse;
- Misc bug fixes and tweaks.

## Version 70200.11

- Exposed `L` table. Will be useful for plugin devs;
- Added option to show quest item toasts regardless of their quality;
- Added Simplified Chinese translation. Translated by y368413@Curse;
- Updated Traditional Chinese translation. Translated by gaspy10@Curse;
- Updated Korean translation. Translated by yuk6196@Curse;
- Updated Russian translation;
- Misc bug fixes and tweaks.

## Version 70200.10

- Project overhaul. New in-game config;
- Added option to change toasts' strata;
- Added option to show ilvl;
- Moved gold toasts to a separate group: Loot (Gold);
- Numerous bug fixes and tweaks.

NOTE: Now this addon is more of a framework, others can hook up to it to show toasts. All built-in toast groups are written as plugins, so you may use them as ref.

## Version 70200.09

- Added 7.2.5 support.

## Version 70200.08

- Fixed toast tooltips;
- Updated Korean translation. Translated by yuk6196@Curse;
- Updated Russian translation.

## Version 70200.07

- Re-release of 70200.05;
- Fixed in-game config issue that led to client freeze.

## Version 70200.06

- Rollback. 70200.05 never happened.

## Version 70200.05

- Reworked skins. All existing skins should work just for now, but you'll have to enable the skin of your choice via in-game config. Skin devs should make some minor adjustments;
- Added countermeasures to limit bloat caused by transmog toasts.

## Version 70200.04

- Fixed bonus roll toast issues.

## Version 70200.03

- Added item toasts stacking. Toasts for identical items that were triggered by the same events will now stack. If two items have similar names, but have different item links and/or come from different events, for example, "CHAT_MSG_LOOT" and "SHOW_LOOT_TOAST", they'll be shown as two different toasts;
- Added Russian translation. Translated by BLizzatron@Cruse and me;
- Misc tweaks.

## Version 70200.02

- Fixed transmog toast issue;
- Fixed profession world quest toast issue;
- Misc tweaks.

## Version 70200.01

- New version format: INTERFACE_VERSION.PATCH;
- Added 7.2 support;
- Added special loot item quality threshold drop down;
- Added Spanish translation. Translated by Gotxiko@GitHub;
- Updated Traditional Chinese translation. Translated by BNSSNB@Curse.

## Version 1.24

- Added "ls: Toasts" config entry w/ "Enable" button to interface options panel. However, It doesn't change the fact that you still need to reload UI after you're done setting up the addon, hence I also added "Reload UI" button;
- Disabled common loot and currency string checks. Hopefully new patterns will perform better, but if I start getting reports about party/raid member loot toasts again, I'll re-enable them;
- Changed addon name's colour so it'll no longer interfere w/ addon list sorting;
- Updated Korean translation. Translated by yuk6196@Curse;
- Updated German translation. Translated by pas06@Curse;
- Numerous bug fixes and tweaks.

## Version 1.23

- First attempt to address issue that made some people receive party/raid members' loot toasts. As of this version if addon detects that necessary variables were modified by another addon, it'll disable common loot and/or currency toasts, you'll be able to see which variables were modified and what addon did it in in-game config. Addon will also start checking if `CHAT_MSG_LOOT`'s 5th param (target) is the same as player's name;
- Updated German translation. Translated by pas06@Curse.

NOTE: Warning preview. !test is my test addon.
![image](http://i.imgur.com/SVPzRN8.png)

## Version 1.22

- Fixed in-game config.

## Version 1.21

- Reworked profile manager. Sadly, I had to reset all settings;
- Added public methods to create, delete, set, and reset profiles. This feature is for addon devs. For more info, read [here](https://github.com/ls-/ls_Toasts#how-to-mod);
- Removed config from global `ls_Toasts` table;
- Updated German translation. Translated by Ithilrandir@Curse.

## Version 1.20

- NEW! Added rated PvP reward toast;
- Added partial German translation. Translated by pas06@Curse;
- Added Traditional Chinese translation. Translated by BNSSNB@Curse;
- Updated Korean translation. Translated by yuk6196@Curse;
- Fixed issues in anchor frame code.

## Version 1.19

- Improved compatibility with other addons that use default alert system to show custom toasts.

## Version 1.18

- Added localisation support. Korean translation by WetU@GitHub;
- Fixed issue in reward button code;
- Fixed issue in follower/champion tooltip code.

## Version 1.17

- Fixed compatibility issues with ElvUI.

## Version 1.16

- Fixed issue that caused transmog toasts not to show proper info;
- Exposed config to other addons. This feature is for addon devs. For more info, read [here](https://github.com/ls-/ls_Toasts#how-to-mod).

## Version 1.15

- Fixed issue in transmog toast code.

## Version 1.14

- Added 7.1 support;
- Reworked transmog toasts. Now they show additions and removals of green, blue and epic appearances;
- Added ilvl upgrade indicator to item toasts.

## Version 1.13

- Added hook to prevent default notifications from being shown;
- Added comparison tooltip to item toasts. Hold "Shift" key to show it. Original code by p3lim@GitHub.

## Version 1.12

- Added currency toast stacking. Instead of creating new toasts for each currency gain, existing one will be updated;
- Added skinning support. This feature is for addon devs. For more info, read [here](https://github.com/ls-/ls_Toasts#how-to-reskin).

## Version 1.11

- Fixed handling of caged battle pets.

## Version 1.10

- Added workaround for few taints.

NOTE: **IMPORTANT!** Now there's no ls: Toasts entry in Interface > AddOns section, but you can create one by using **/lstoasts** command. After that you'll be able to access config panel the old way. However, I strongly recommend to **/reload** UI after you're done setting up the addon. Even if you opened and closed config panel without changing anything, **/reload UI**. By doing so, you'll remove config entry from the system and prevent possible taints. Blame Blizzard, not me.

## Version 1.09

- Split "Garrison" toast group into two new groups: "Garrison" and "Class Hall";
- Moved currency toasts to a new category, "Loot (Currency)";
- Misc bug fixes and tweaks.

## Version 1.08

- Fixed "SetPortraitToTexture" error.

## Version 1.07

- NEW! Added common loot toasts;
- Reworked in-game config a bit;
- Misc bug fixes and tweaks.

## Version 1.06

- NEW! Added transmog toast;
- NEW! Added an option to colour item, follower names by quality, and world quest, mission titles by rarity. Original code by WetU@GitHub;
- NEW! Added options for horizontal growth directions;
- NEW! Added /lstoasts slash command;
- Fixed missing toast sounds;
- Misc bug fixes and tweaks.

## Version 1.05

- Fixed anchor frame movement, when it's scaled down.

## Version 1.04

- NEW! Added scaling for toasts;
- Fixed an issue in fade out delay code.

## Version 1.03

- NEW! Added an option to save settings as a default preset that will be used for all characters;
- NEW! Added fade out delay slider.

NOTE: Saving settings is an experimental feature, if feedback is negative, I may replace it with a typical profile manager.

## Version 1.02

- Fixed issue in garrison toast test.

## Version 1.01

- Release released.
