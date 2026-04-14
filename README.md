# ⚔️ [Magika Spell]

> An original 8-bit turn-based RPG developed from scratch using Lua and the LÖVE framework, featuring a robust custom state machine and original retro assets.

![Gameplay Demo](assets/gameplay.gif)

*A quick look at the transition from Intro State to Explore State*

---

## 🛠️ Tech Stack & Tools

This project was built entirely from the ground up, handling everything from the core engine logic to the visual and audio assets:

* **Engine/Language:** Lua running on the [LÖVE (Love2D) framework](https://love2d.org/)
* **Visual Assets:** Custom sprites, character models, and UI elements designed and animated in **Aseprite**.
* **Audio Production:** Original 8-bit retro-style background music and sound effects synthesized using **FL Studio** and the **Vital** plugin.

---

## ⚙️ Core Architecture: The State Machine

To handle the complex flow of an RPG, the game utilizes a custom, robust State Machine architecture. This allows for seamless memory management and logic separation between different phases of gameplay:

* `Intro_state`: Handles the title screen, main menu, and initialization variables.
* `Explore_state`: Manages the overworld grid movement, NPC interactions, and collision detection.
* `Battle_state`: Controls the turn-based combat math, enemy AI logic, and inventory/skill selection.

---

## 🎨 Asset Showcase

### Character Sprites
![Main Character Sprite](assets/mage1.png) ![Enemy Sprite](assets/Slime1.png)
*Custom animations drawn in Aseprite.*

### Audio Tracks
Listen to the original 8-bit soundtrack here:
[Link to your SoundCloud, YouTube, or Google Drive folder]

---

## 🚀 How to Run the Game

To play the current build locally on your machine:

1. **Install LÖVE:** Download and install the LÖVE framework from [love2d.org](https://love2d.org/).
2. **Clone the repository:**
   ```bash
   git clone [https://github.com/Sakda-Thiraprarom/YOUR-REPO-NAME.git](https://github.com/Sakda-Thiraprarom/YOUR-REPO-NAME.git)
