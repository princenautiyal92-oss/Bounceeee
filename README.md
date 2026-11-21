# SNAPBACK (Godot 4 Engine Project)

A clean 2D physics-platformer built directly for **Godot 4** centered around the hackathon theme: **"Setbacks are your fuel"**.

---

## What's in the Game

1. **Recoil = Tension Fuel**: 
   - Hazards (bumpers and moving enemies) knock you backward and fill your **Tension Bar**.
2. **The Snapback Dash (`SHIFT` / `E`)**: 
   - Converts stored tension into an explosive forward dash that launches you across bottomless chasms.
3. **Moving Enemies**:
   - Purple patrol bots that pace back and forth.
   - If they bump into you normally, they knock you back and charge your Tension.
   - If you **Snap** through them, you defeat them for **+250 bonus points**!
4. **Point System**:
   - Collectible gold coins scattered across platforms and floating over chasms (+100 points each).
   - Defeating enemies with Snap (+250 points).
   - Real-time score displayed in the HUD.
5. **10 Complete Levels**:
   - Progression from basic bumper tutorials to moving enemy gauntlets and canyon leaps.

---

## Controls

- **Move Left / Right**: `A` / `D` or `Arrow Keys`
- **Jump**: `Space` or `W`
- **Snapback Dash**: `Shift` or `E`
- **Quick Restart**: `R`

---

## Project Structure

```
gamedev/
├── project.godot               # Godot 4 configuration (starts at level_1.tscn)
├── assets/
│   └── sprites/                # 6 simple 32x32 retro pixel sprites
│       ├── player.png          # Blue player core
│       ├── ground.png          # Dark platform tile
│       ├── bumper.png          # Red spring bumper
│       ├── goal.png            # Green goal flag
│       ├── enemy.png           # Purple patrol bot
│       └── coin.png            # Shiny gold coin
├── scenes/
│   ├── player.tscn             # CharacterBody2D + Camera2D + Tension & Score HUD
│   ├── bumper.tscn             # Area2D knockback hazard
│   ├── enemy.tscn              # Moving patrol enemy
│   ├── coin.tscn               # Area2D point collectible
│   ├── goal.tscn               # Level transition flag
│   └── levels/                 # 10 playable levels (level_1.tscn to level_10.tscn)
└── scripts/
    ├── player.gd               # Movement, tension, snap, and score tracking
    ├── bumper.gd               # Knockback impulse & tension gain
    ├── enemy.gd                # Left-right patrol movement & interaction
    ├── coin.gd                 # Point collection
    └── goal.gd                 # Next level loader
```
