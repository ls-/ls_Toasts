## ls: Toasts
Replacement for default alert system. Better toasts, cheers!

![image](http://i.imgur.com/PvzX6VF.gif)

## Download
- [WoWInterface](http://www.wowinterface.com/downloads/info24123.html)
- [Curse](http://mods.curse.com/addons/wow/ls-toasts)

## Features
- One design for all toasts. Special alert frames have unique backgrounds;
- In-game config at Esc > Interface > AddOns > ls: Toasts. From there you can disable sounds, move alert frames, etc;
- DND mode. You can enable DND mode for different toast groups. Toasts in DND mode won't be displayed in combat, but will be queued up in the system. Once you leave combat, they'll start popping up. Available from in-game config;

## Usage
- Install it;
- _(Optional)_ Configure it;
- Done.

## Feedback And Feature Requests
If you found a bug or want to share an idea on how to improve my addon, either report to [Issue Tracker](https://github.com/ls-/ls_Toasts/issues) on my GitHub page, or post a comment on [WoWInterfrace](http://www.wowinterface.com/downloads/info24123.html#comments) or [Curse](http://mods.curse.com/addons/wow/ls-toasts#comments).

## FAQ
**Q:** Will you add group/master loot frames to your addon?
**A:** Yeah, but a bit later, first I need to figure out how these loot roll systems work.

**Q:** Will you add normal loot toasts, like "Loot Toasts" does?
**A:** I'm not sure about it yet. There is one major problem, there's no proper loot-related event that fires, when you loot something. I'll have to listen to CHAT_MSG_* events to get info. But it may be quite difficult to avoid toast doubles. Let's say you rolled and won a [Sword], you'll get a message about it (CHAT_MSG_LOOT event), and a toast will pop up (LOOT_ITEM_ROLL_WON event). Before addon shows a toast, it'll need to make sure that it's exactly same sword and not two identical swords, that you happened to receive simultaneously, but one was picked up and another one was won via roll. They have same IDs, and item links may be identical. Before I add normal loot toasts, I'll have to find a good way to handle such scenarios.

## License
Please see [LICENSE](https://github.com/ls-/ls_Toasts/blob/master/LICENSE.txt) file.
