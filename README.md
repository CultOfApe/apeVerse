# apeVerse disclaimer

Reason for creating this repository is that I wanted to separate game and framework development, and since I´m focused on finalizing the framework right now, most development will happen here for the foreseeable future. All artwork in-game is placeholder, some quickly thrown together by me, and some shamelessly borrowed until I get to making my own. Engine and editor functionality is prioritized right now.

The game is created with the latest Godot 4.0 nightly build before the Vulkan merge, and likely won´t run in 3.2.x so if you want to edit the game in Godot, you need to rename apeverse.exe into godot.exe.

# What is apeVerse?

apeVERSE is an adventure game framework built with Godot (GDscript), currently in very early development.

At the moment, functionality is limited, with some functionality hardcoded and not editable outside of GDscript, this will change over time.

Alpha one functionality:

- Point´n´click movement and interaction (functional, mostly done)
- Dialogue/Event system (functional, mostly done)
- Map, inventory and phone interfaces (functional, mostly done, need refactoring to make more modular)
- Day/Night system (functional, but hacky, and needs refactoring)
- Save system (proof-of-concept stage, needs better design)

Editor functionality:

- Basic dialogue editor (currently displays dialogue trees, but no editing possible)

All 3d scenes are treated as flat surfaces by the engine, meaning it will only have to worry about 2 axis. The game isn´t even aware of the floor, you simply need to place the character at floor level, since it doesn´t move up or down. .You can of course make a scene that doesn´t have only flat surfaces, but you need to make sure to set up collision objects so that the player doesn´t walk through the terrain.

# Design documents

These are a bit out-of-date, but serve to explain how the dialogue/event system works:

Ape´s Dynamic Dialogue System (ADDS) - dialogue JSON structure:
https://docs.google.com/document/d/10JHm-Dq9DuULpQpPpKmPTZXTJBKEw0tCD9WauN_B3RE/edit?usp=sharing

Ape´s Dynamic Dialogue System (ADDS) - code document:
https://docs.google.com/document/d/1Fk2ibcrorJhD-_Byec9JRJN6CGQvNFMw9pUllVV94jA/edit?usp=sharing

# What are the future plans for apeVerse?

At the moment ApeVERSE is a 3D adventure game framework with a dialogue editor, but the longterm goal is to make it a complete game engine, where full games can be constructed entirely through the built-in editor. ApeVerse is built to take the simplest path to productivity always. I´m creating it for my own games, and thus (for now) I will be developing the bare minimum feature set needed in order to get my game done. Until external intereset is shown, features implemented will be dictated by my own personal needs. Games that will be possible are:

2d, 2.5d and 3d point´n´click adventure games (ex. Sierra style games)
Visual Novels (ex. Ren´py)
Possibly ARPGs... but that´s a low priority

I don´t currently plan to implement a verb system (eg. LucasArts games)

# Is apeVerse ready for serious projects?

No, it´s certainly possible to use it for smaller games, but it currently requires knowledge of the Godot editor, GDscript and JSON.

Luckily there are several adventure game/Visual Novel frameworks for Godot on GitHub that are more feature complete, and might meet your requirement:

Rakugo (https://github.com/rakugoteam/Rakugo)
GOAT (https://github.com/miskatonicstudio/goat)
YUME (https://github.com/yumedev40/Yume-Visual-Novel-Editor)
