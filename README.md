# apeVerse disclaimer

Featurewise, this is basically the same as the philtroyGodot3 branch, with a bunch of code refactoring/simplification, fixes and new graphics.

Reason for creating this repository is that I wanted to separate game and framework development, and since I´m focused on finalizing the framework right now, most development will happen here for the foreseeable future.

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

# What are the future plans for apeVerse?

At the moment ApeVERSE is a 3D adventure game framework with a dialogue editor, but the longterm goal is to make it a complete game engine, where full games can be constructed entirely through the built-in editor. Until external intereset is shown, features implemented will be dictated by my own personal needs. Games that will be possible are:

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
