# ls: Toasts

Replacement for default alert system. Better toasts, cheers!

![image](http://i.imgur.com/PvzX6VF.gif)

## Download

- [WoWInterface](http://www.wowinterface.com/downloads/info24123.html)
- [Curse](http://mods.curse.com/addons/wow/ls-toasts)

## Features

- One design for all toasts. Special alert frames have unique backgrounds;
- In-game config. Use **/LSTOASTS** or **/LST** command to open config panel. From there you can disable sounds, move alert frames, etc;
- DND mode. You can enable DND mode for different toast groups. Toasts in DND mode won't be displayed in combat, but will be queued up in the system. Once you leave combat, they'll start popping up;

## Usage

- Install it;
- _(Optional)_ Configure it;
- Done.

## How to Mod

If you're UI developer, you may want to reskin my toasts. To create a skin you need to do the following:

```Lua
local toast_F = ls_Toasts[1]

toast_F:CreateSkin("skin_name", function(toast)
  -- do something here
end)
```

This function is called after colours, textures and texts are set, but before toast is shown. Toast and its type are passed as arguments.

If you want to activate your skin right away, add this line to your code:

```Lua
toast_F:SetSkin("skin_name")
```

Skin activation is optional, users can switch skins via in-game config.

**Note:** For toast's structure see `ConstructToast` function in `core.lua`.

## Feedback and Feature Requests

If you found a bug or want to share an idea on how to improve my addon, either report to [Issue Tracker](https://github.com/ls-/ls_Toasts/issues) on my GitHub page, or post a comment on [WoWInterfrace](http://www.wowinterface.com/downloads/info24123.html#comments) or [Curse](http://mods.curse.com/addons/wow/ls-toasts#comments).

## Localisation

Feel free to add and/or review translations on [CurseForge](https://wow.curseforge.com/addons/ls-toasts/localization/), alternatively you can create a PR on [project's GitHub page](https://github.com/ls-/ls_Toasts/pulls).

## FAQ

**Q:** Will you add group/master loot roll frames to your addon?

**A:** Maybe later, I'm not sure yet.

## License

Please see [LICENSE](https://github.com/ls-/ls_Toasts/blob/master/LICENSE.txt) file.
