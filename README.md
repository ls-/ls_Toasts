## ls: Toasts
Replacement for default alert system. Better toasts, cheers!

![image](http://i.imgur.com/PvzX6VF.gif)

## Download
- [WoWInterface](http://www.wowinterface.com/downloads/info24123.html)
- [Curse](http://mods.curse.com/addons/wow/ls-toasts)

## Features
- One design for all toasts. Special alert frames have unique backgrounds;
- In-game config. Use **/LSTOASTS** _(el ess toasts)_ command to open config panel. From there you can disable sounds, move alert frames, etc;
- DND mode. You can enable DND mode for different toast groups. Toasts in DND mode won't be displayed in combat, but will be queued up in the system. Once you leave combat, they'll start popping up. Available from in-game config;

## Usage
- Install it;
- _(Optional)_ Configure it;
- Done.

## How to Mod
If you're UI developer, you may want to reskin my toasts. To do so, you'll need to override special dummy function by adding something like this to your addon code:

```Lua
local toast_F = ls_Toasts[1]

function toast_F:SkinToast(toast, toastType)
	-- do something here
end
```

This function is called after colours, textures and texts are set, but before toast is shown. Toast and its type are passed as arguments.

**Note #1:** For toasts' structures see definitions of `CreateBaseToastButton` and `GetToast` functions.

You can create, set, reset, and deleted profiles.

```Lua
local toast_F = ls_Toasts[1]

-- create new "test" profile and activate it
local created, reason = toast_F:CreateProfile("test")

-- delete "test" profile
local deleted, reason = toast_F:DeleteProfile("test")

-- activate existing "test" profile
local set, reason = toast_F:SetProfile("test_profile")

-- reset existing "test" profile to defaults
local reset, reason = toast_F:ResetProfile("test_profile")

```

**Note #2:** For more info on arguments and returns see definitions of `F:CreateProfile`, `F:DeleteProfile`, `F:SetProfile`, and `F:ResetProfile` functions.

## Feedback and Feature Requests
If you found a bug or want to share an idea on how to improve my addon, either report to [Issue Tracker](https://github.com/ls-/ls_Toasts/issues) on my GitHub page, or post a comment on [WoWInterfrace](http://www.wowinterface.com/downloads/info24123.html#comments) or [Curse](http://mods.curse.com/addons/wow/ls-toasts#comments).

## Localisation
Feel free to add and/or review translations on [CurseForge](https://wow.curseforge.com/addons/ls-toasts/localization/), alternatively you can create a PR on [project's GitHub page](https://github.com/ls-/ls_Toasts/pulls).

## FAQ
**Q:** Will you add group/master loot roll frames to your addon?<br/>
**A:** Maybe later, I'm not sure yet.

## License
Please see [LICENSE](https://github.com/ls-/ls_Toasts/blob/master/LICENSE.txt) file.
