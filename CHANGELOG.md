# CHANGELOG

## Version 110200.02

### Loot (Currency)

- Fixed an issue during the currency transfer.

## Version 110200.01

- Added 11.2.0 support.

## Version 110107.01

- Added 11.1.7 support.

## Version 110105.01

- Added 11.1.5 support.

### Loot (Common) & Loot (Special)

- Added an option to suppress toasts for legacy armour and weapons. You can disable toasts for legacy equipment by
  unchecking /LST > Toast Types > Loot (Common|Special) > Legacy Equipment, enabled by default.

## Version 110100.01

- Added 11.1.0 support.

### Achievement

- From now on only new achievements will be toasted. You can enable toasts for previously earned achievements at /LST >
  Toast Types > Achievement > Earned.

### Collection

- Added Warband Scene aka Campsite toasts.

## Version 110005.01

- Added 11.0.5 support.
- Added a set of AzeriteUI themed skins.
- Added missing Beautycase (Legacy) skin.
- Updated Spanish translation. Translated by Distopic@Curse.

## Version 110002.03

- Removed the workaround for the guild achievement spam. It's finally fixed by Blizzard. An ancient bug that had been
  ignored for years got fixed asap after it showed up multiple times during RWF streams and caused a few wipes.

## Version 110002.02

- Reworked the workaround for the guild achievement spam. After further investigating the issue it became apparent that
  it's impossible to reliably automate it without affecting newer smaller guilds that might want to see toasts for these
  achievements. For this reason I'm adding a toggle to enable filtering for guild achievements if your guild is
  experiencing it. This will block toasts for a bunch of faction-specific PvP and reputation achievements. Can be found
  at /LST > Toast Types > Achievement > Filter Guild Achievements, disabled by default.
- Updated Traditional Chinese translation. Translated by BNS333@Curse.

## Version 110002.01

- Added a workaround for buggy guild achievement spam. If your character is in a guild, the addon will add already
  completed guild achievements to the blacklist on log in, you still will be able to see guild achievements if they're
  earned for the first time. If you join a guild at some point, reload the UI, the achievement API is super laggy, so I
  avoid rebuilding the blacklist during the actual game session.
- Added an option to disable tooltips on mouseover.

## Version 110000.02

- Fixed "[DNT] Worldsoul Memory Score" toasts.

## Version 110000.01

- Added 11.0.0 support.

## Version 100207.02

- Fixed an issue where the archive wouldn't extract properly for Mac and Linux users.

## Version 100207.01

- Added 10.2.7 support.

## Version 100206.01

- Added 10.2.6 support.

## Version 100205.03

### Loot (Special)

- Added loot roll info. It's a returning feature. However, there's a caveat, I don't know if "transmog" rolls are
  actually a thing in this particular case because it's basically an undocumented feature. I added it based on my
  assumptions, so if it works, good, if it doesn't, oh well. But "need", "greed", and "disenchant" rolls should work as
  expected.

![Imgur](https://i.imgur.com/s1VB5Lk.png)

## Version 100205.02

- Added partial Brazilian Portuguese translation. Translated by paulovnas@GitHub.

## Version 100205.01

- Added 10.2.5 support.

## Version 100200.01

- Added 10.2 support.
- Added "LS: Toasts" entry to the addon compartment in the top right corner of the minimap.
- Tweaked toast borders so that the texture looks more consistent with no warping or shifting.
  Doesn't affect ElvUI skins.

### Transmogrification

- Fixed an issue where sometimes a toast wouldn't show up. It's primarily affecting "Quantum Items" that unlock
  a random appearance on use.

![Imgur](https://i.imgur.com/VbQfaNq.png)
![Imgur](https://i.imgur.com/iwnsoda.png)

## Version 100105.01

- Added 10.1.5 support.

## Version 100100.03

- Added "Two Tone" variants to all built-in skins. They have a two tone background that's similar to that of Blizz
  achievement toasts. I might tweak the textures depending on the feedback.
- Updated Spanish translation. Translated by Shacoulrophobia@Curse.

![Imgur](https://i.imgur.com/2QWIHCd.png)

## Version 100100.02

- Fixed world quest toasts.

## Version 100100.01

- Added 10.1.0 support.

## Version 100007.01

- Added 10.0.7 support.

## Version 100005.03

- Added "Traveler's Log" toasts for monthly activities.

### Loot (Currency)

- Added support for Trader's Tenders. They might be buggy due to how they're implemented on Blizz end. Unlike other
  currencies these update reliably only when the Trading Post UI is shown, that's why if you gain them while you're away
  from the Trading Post you may or may not get the toast.

## Version 100005.02

### Loot (Common)

- Reworked the reagent and crafted item quality icon.

![Imgur](https://i.imgur.com/oZomyJR.png)

## Version 100005.01

- Added 10.0.5 support.

### Loot (Common)

- Added support for reagent ranks.

### Loot (Currency)

- Updated the currency blacklist.

## Version 100002.02

- Fixed "10.0 Dragonrider PVP - Whirling Surge Dismounts" spam.
- Updated French translation. Translated by agstegiel@Curse and Braincell1980@Curse.
- Updated German translation. Translated by MrKimab@Curse.

## Version 100002.01

- Added 10.0.2 support.
- Fixed an issue where the addon would load the achievement UI too early which in turn could cause
  errors.

## Version 100000.03

- Fixed file loading order.

## Version 100000.02

- Added an option to show poor quality quality items via common loot toasts. Thanks to Faqar@GitHub.
- Added leaf ornaments to achievement toasts. I can't re-enable Blizz achievement toasts, so as a
  compromise I chose to make achievement toasts more unique. If you want them to stand out even more
  create a separate anchor to display them.
- Fixed an issue where repeatedly testing toasts and flushing the queue would sometimes lock up the
  addon.
- Fixed corrupt beautycase border texture. It worked, but baked-in shadows were messed up.
- Updated Traditional Chinese translation. Translated by BNS333@Curse.

![Imgur](https://i.imgur.com/yqJ7C6S.png)

## Version 100000.01

- Added 10.0.0 support;
- Added new "Info" panel to the config. It has links to various resourced including my Discord
  server dedicated to LS: * addons;
- Renamed "Recipe" toasts to "Profession". Added profession skill line toasts;
- Updated "Collection" toasts;
- Updated embeds.

## Version 90207.01

- Added 9.2.7 support;
- Fixed an issue where archaeology toasts would show the loss of fragments;
- Fixed an issue where currency toasts would show decimals for quantities;
- Updated Traditional Chinese translation. Translated by RainbowUI@Curse.

## Version 90200.01

- Added 9.2.0 support;
- Updated French translation. Translated by agstegiel@Curse.

## Version 90105.01

- Added 9.1.5 support.

## Version 90100.03

- Fixed "Torghast - Scoreboard" toast spam. Once again. Blizz continue adding
  more info with hotfixes, so this most likely isn't the last spam fix. 

## Version 90100.02

- Fixed "Torghast - Scoreboard" toast spam.

## Version 90100.01

- Added 9.1.0 support.

## Version 90005.01

- Added 9.0.5 support.

## Version 90002.01

- Added 9.0.2 support.

## Version 90001.04

- Added Italian translation. Translated by vabatta@GitHub;
- Updated Korean translation. Translated by unrealcrom96@Curse;
- Updated Traditional Chinese translation. Translated by RainbowUI@Curse.

## Version 90001.03

- Added currency toast filters. They will allow you to blacklist certain currencies entirely and
  to set thresholds below which toasts won't be generated. The addon will try to populate the
  currency list with discovered currencies automatically, thus you should log in on a character
  that discovered them most currencies at least once, but there's a way to add currency IDs
  manually. Out of the box, the only active currency filter is for `"Honor"`, it's set to 25; 
- Updated Traditional Chinese translation. Translated by RainbowUI@Curse.

![](https://i.imgur.com/zpXx0KW.png)

## Version 90001.02

- Added support for runecarving toasts which become available later after SL launch;
- Added honour throttling for currency toasts. For the time being any honour gains below 20
  will be ignored to avoid any toast spam in BGs. It's a temporary measure, I'll replace it
  with proper currency filtering later.

## Version 90001.01

- Added 9.0.1 support.

## Version 80300.02

- Fixed an issue where currency loss toasts were incorrectly treated and shown as gains.

## Version 80300.01

- Added 8.3.0 support;
- Added support for corrupted items;
- Added BeautyCase-like skin;
- Gold toast's icon now has three states: copper, bronze, and gold;
- Updated Korean translation. Translated by blacknib@Curse;
- Misc bug fixes and tweaks.

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 80205.01

- Added 8.2.5 support;
- Moved all Blizz store-related toasts to their own group: Shop. Revamped Recruit-a-Friend rewards
  will be handled by this group as well;
- Misc bug fixes and tweaks.

## Version 80200.06

- Fixed "Artifact Fragment" currency spam in Ashran. If you encounter similar issues in the future  
  feel free to report them. There's a number of unusual currencies in the game that behave  
  differently from others, so manual adjustments are needed to handle them properly.

## Version 80200.05

- Colour texts that indicate some sort of loss, i.e., "You Lost", "Appearance Removed", red;
- Updated Simplified Chinese translation. Translated by vk1103ing@Curse;
- Misc bug fixes and tweaks.

## Version 80200.04

- Added an option to show currency losses. Disabled by default;
- Added fragment toasts to the "Archaeology" group;
- Updated Simplified Chinese translation. Translated by vk1103ing@Curse;
- Updated Traditional Chinese translation. Translated by BNS333@Curse.

## Version 80200.03

- Re-added copper threshold to gold toasts;
- Made gold loss tracking optional. Enabling this feature will make gold toasts ignore set copper  
  threshold. Disabled by default;
- Updated German translation. Translated by Merathilis@Curse;
- Updated Korean translation. Translated by netaras@Curse;
- Updated Spanish translations. Translated by Gotxiko@Curse;
- Updated Traditional Chinese translation. Translated by BNS333@Curse.

## Version 80200.02

- Rewrote gold toasts to display money gains and losses. Removed the copper threshold option  
  because it's interfering with the new functionality;
- Updated embeds.

## Version 80200.01

- Added 8.2.0 support;
- Added Ctrl-Left-Click support to transmog, toy, mount, and item toasts to show the dressing room
  frame;
- Updated embeds.

## Version 80100.10

- Added "ToastCreated", "ToastSpawned", and "ToastReleased" callbacks. As always, callbacks use  
  CallbackHandler-1.0;
- Renamed toasts' Recycle method to Release. Recycle is still available, but is deprecated;
- Renamed "SetSkin" and "ResetSkin" callbacks to "SkinSet" and "SkinReset". "SetSkin" and  
  "ResetSkin" are still available, but are deprecated;
- Fixed toasts' border's tiling;
- Updated embeds.

## Version 80100.09

- Updated anchors' config code.

## Version 80100.08

- Added a workaround for a Blizz bug which prevents item tooltips from being rendered correctly.

## Version 80100.07

- Added 8.1.5 support.

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
