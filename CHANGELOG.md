## Version 1.21

- NEW! Reworked profile manager. Sadly, I had to reset all settings;
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
