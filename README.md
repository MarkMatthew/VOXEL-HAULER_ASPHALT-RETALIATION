# VOXEL HAULER: ASPHALT RETALIATION
### Version 1.0 — 3D Arcade Motor Hauling

[![Godot Engine](https://img.shields.io/badge/Godot-4.7-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Web-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()

A high-octane 3D arcade trucking game built on **Godot 4** and playable directly in the browser via **WebGL / Vercel**. Deliver high-value industrial supplies across dense highway traffic, battle aggressive road hazards, accumulate Road Rage, and unleash twin roof-mounted machine-gun turrets in **Retaliation Mode**!

---

## 🎮 Game Concept & Mechanics

```
DRIVE ➔ NAVIGATE ➔ TRAFFIC CONFLICT ➔ RAGE ➔ RETALIATION ➔ POLICE PURSUIT ➔ DELIVERY ➔ SCORE
```

1. **Class 8 Semi-Truck & Articulated Trailer:**
   - 105 MPH top speed with heavy diesel torque, speed-sensitive steering inertia, and air-brake sound effects.
   - Top-level trailer hitch kinematics with realistic swing and zero physics instability.
2. **Interactive 3D Showroom Garage:**
   - **REDLINE:** Crimson Red with polished chrome accents.
   - **BLUE THUNDER:** Electric Blue with neon cyan trim.
   - **NIGHT RIDER:** Midnight Black with stealth gunmetal plating.
3. **Four-Lane Highway & Exit 42B Interchange:**
   - 2.4 km asphalt route with concrete Jersey barriers, overhead gantries, and streetlights.
   - Approaching Exit 42B triggers large glowing yellow chevron exit arrows on the roadway and large HUD announcements: `➔ RIGHT EXIT 42B — 800 FT ➔`.
4. **Traffic Hazards & Provocateurs:**
   - Multi-class civilian traffic (Sedans, SUVs, Sports Cars, Pickups, Vans).
   - Aggressive drivers cut into your lane and brake-check, displaying floating 3D billboard `⚠ BRAKE!` warnings overhead.
5. **5-Tier Road Rage System:**
   - Calm (0–24%) ➔ Annoyed (25–49%) ➔ Furious (50–74%) ➔ Critical (75–99%) ➔ **RETALIATION READY (100%)**.
6. **Dual-Turret Retaliation Mode:**
   - At 100% rage, press `SPACE` to deploy twin machine-gun turrets.
   - Camera widens, candidate targets receive 3D corner brackets (`TAB` to cycle targets), and Left Click discharges rapid twin arcade tracers.
   - Offending vehicles explode into 22 scattering voxel debris fragments!
7. **5-Star Police Heat & Pursuit AI:**
   - Escalating heat draws black-and-white pursuit cruisers with alternating red/blue lightbars and sirens attempting PIT maneuvers.
8. **Delivery Mission & Scoring:**
   - Pull into the illuminated yellow hazard delivery bay at **Riverside Logistics Center** to complete the run.
   - Scoring grades performance from **S** to **D** based on time, cargo preservation %, truck durability, clean driving bonus, and police penalties.

---

## 🕹 Controls

| Action | Key / Input |
| :--- | :--- |
| **Accelerate** | `W` or `Up Arrow` |
| **Brake / Reverse** | `S` or `Down Arrow` |
| **Steer Left / Right** | `A` / `D` or `Left` / `Right` |
| **Activate Retaliation** | `Spacebar` (at 100% Rage) |
| **Fire Turrets** | `Left Mouse Button` / `F` |
| **Cycle Targets** | `Tab` |
| **Toggle Camera Distance** | `C` |
| **Recover Stuck Truck** | `R` |
| **Pause Game** | `Escape` |

---

## 🚀 Running the Game

### Native Desktop (macOS / Windows)
Open with Godot 4:
```bash
godot
```
Or launch headless automated verification suite:
```bash
godot --headless res://src/tests/test_scene.tscn
```

### Web / Vercel
Deploy directly to Vercel:
```bash
npx vercel --prod
```
Or connect this GitHub repository in your Vercel project dashboard at [vercel.com/antigravity25/voxel](https://vercel.com/antigravity25/voxel/settings/git).
