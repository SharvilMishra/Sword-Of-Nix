# Sword Of Nix

*A city in shadow. One blade against the night.*

**Sword Of Nix** is a single-player 2D cyberpunk action-platformer made with Godot 4.7. Take the role of the Blue Wraith, a masked swordsman cutting through rain-soaked Nix City. Fight across the rooftops, break into the Akai Hideout, and face the Warden.

## Features

- Fast side-scrolling combat with directional katana slashes and projectile parries.
- A two-jump limit, one-way platforms, and a forward Focus Dash.
- Press **E** to activate Focus: you move normally while the world slows for 3 seconds. The 10-second cooldown starts on activation.
- Three player HP with brief damage protection and clear health feedback.
- Story prologue, rooftop mission, multi-floor hideout, Warden battle, and an ending sequence.
- Local level progression, an all-level select menu, and a cyberpunk-paintstroke title menu.
- Separate music for the menu and regular stages versus story and boss battles.

## Play

### Open in Godot

1. Install Godot 4.7 or a compatible newer version.
2. Open the Sword_Of_Nix project folder and select project.godot.
3. Let Godot import the project, then press **F5** to run the project's main scene.

### Run from a terminal

From inside the Sword_Of_Nix project folder, run:

    godot --path .

To open the project in the editor from the terminal:

    godot --editor --path .

These commands require the Godot executable to be available as godot in your terminal. If it is not, run the command with the full path to your Godot executable.

## Controls

| Input | Action |
| --- | --- |
| A / D or Left / Right | Move |
| Space | Jump, up to two times before landing |
| Hold S / Down, then press Space | Drop through a one-way platform |
| J, X, or left-click | Slash and parry |
| Press E | Focus slows the world for 3s; 10s cooldown starts on activation |
| Hold D + R | Focus Dash and slash forward |
| F | Continue story dialogue |
| Backspace | Restart the current level or room |
| Touchscreen | Move backward/forward on the left; jump, Skill, and slash on the right |
| Touchscreen top-right | Continue story and pause |
| Esc | Open the battle menu: Leave Battle, Resume, or Restart |

## Android build

The project uses landscape orientation on phones and shows translucent touch controls during play. The left side handles backward/forward movement; jump, Skill, and slash are on the right. Skill remains a tap-to-activate ability: the world slows for 3 seconds, then the 10-second cooldown begins.

An Android export preset is included. In Godot 4.7.2, open **Project > Export**, select **Android**, and export a debug APK to `dist/SwordOfNix-android-debug.apk`. Android export requires matching Godot export templates, JDK 17, and the Android SDK configured in Editor Settings. The debug build is for personal device testing; public release builds should use a release keystore that you control.

## Progress and saves

Progress is saved locally on your device through Godot's user:// save location. Clearing a stage unlocks the next one. The title screen includes **Level Select**, which lists every campaign stage and marks it cleared, available, or locked. Cleared and unlocked stages can be replayed without erasing progression. Saves are local; the game does not require an account or online service.

## Music

- **Headlights on Wet Pavement** - title menu and regular stages.
- **Steel Against the Horizon** - story prologue and Warden battle.

## Project structure

| Folder or file | Contents |
| --- | --- |
| project.godot | Godot project settings and main scene configuration. |
| scenes/ | Title screen, story, rooftop, hideout, and boss scenes. |
| scripts/ | Player, enemies, combat, story, menus, audio, and save logic. |
| assets/ | Character, environment, story, audio, font, and UI assets. |
| BGM SONG/ | Main game music tracks. |
| data/ | Story content, localization, and game data. |
| docs/ | Project guide, entity design notes, and asset notices. |
| test/ | Project verification scripts. |

For additional gameplay and entity details, see the [project guide](docs/UMBRAL_RUN_README.md) and [entity design catalogue](docs/ENTITY_DESIGNS.md).

## Credits and asset use

This project includes third-party and generated assets. Review the relevant notices and provenance records in docs/ and alongside the assets before reusing or redistributing them. No separate license for the complete game is declared here; ask before treating the entire project as open source.
