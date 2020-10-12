**About**

PoliLevelUtil is an addon that gives you the ability to record leveling data and export it to the saved variables in a JSON format.Once exported, a separate tool can be used to perform analytics and generate spreadsheets.

**Requirements**

This addon is meant to be used with a separate Java program to generate spreadsheets from the saved variables created by the addon. It can be found here: https://github.com/AdamHayse/QuestUtility-Shadowlands

In order to generate spreadsheets using the addon, you need some amount of technical knowledge as well as the following software:

- Java 11
- Microsoft Excel
- an Integrated Development Environment (IDE) that supports Java and Apache Maven
- Windows (probably, but not sure)

**Commands**

Type "**/plu start <optional name>**" to start a recording.

Type "**/plu stop**" to stop a recording.

Type "**/plu list**" to show a list of all recordings since login.

Type "**/plu delete <recording name>**" to delete a recording created since login.

**Finer details on usage**

- If a name isn't provided when executing `/plu start`, then a default name for the recording will be created.
- Only one recording can be in-progress at a time.
- Recordings cannot be restarted once stopped.
- Reloading UI doesn't stop a recording.
- Reloading UI can be used to write in-progress recordings to the saved variables.
- In-progress recordings are included in spreadsheet generation.
- Logging out while recording will stop the recording and do all the necessary cleanup as if you typed `/plu stop`.
- Recordings that are in progress cannot be deleted until they are stopped.
- Recordings can have shared names.
- In order to delete a recording with a shared name, you must also specify the recording number provided by `/plu list`.
- If the game closes due to crashing, you will lose all recording data since your last UI reload.
- Sessions that have no recordings will not be preserved upon logging out.

**Demo Video**

<Coming soon>

[Discord Link](https://discord.gg/nc4ECEw "Discord")

[Curseforge Link](https://www.curseforge.com/wow/addons/poli-leveling-util)

**Contribute**

If you want to support my work, you can share it with your friends or offer constructive feedback or propose features that you think you and other people would like.

If you want to contribute more, you can create pull requests for this addon, write unit tests for the Java project that goes with it, or you can donate to my PayPal.

[![PayPal Button](https://www.paypalobjects.com/en_GB/i/btn/btn_donate_LG.gif "Donate")](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=WW4YMCEMJMWVW&item_name=Polihayse+WoW+addon+development&currency_code=USD&source=url)
