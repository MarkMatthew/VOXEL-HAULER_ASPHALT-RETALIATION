# VOXEL HAULER: ASPHALT RETALIATION
### Version 1.2 — Visual Quality & Vehicle Collision Upgrade

[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Vercel%20%7C%20macOS%20%7C%20Windows-blue)]()
[![Graphics](https://img.shields.io/badge/Graphics-3D%20Voxel%20Arcade-orange)]()
[![Physics](https://img.shields.io/badge/Physics-4--Hit%20Push%20Impulse-red)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()

A high-octane 3D arcade trucking game playable directly in the browser via **WebGL / Vercel** (with native Godot desktop support). Deliver high-value industrial supplies across busy highways, push through traffic with realistic multi-hit vehicle collisions, battle aggressive road hazards, accumulate Road Rage, and unleash twin roof-mounted machine-gun turrets in **Retaliation Mode**!

---

## 🎮 Game Concept & Mechanics

```
DRIVE ➔ NAVIGATE ➔ TRAFFIC CONFLICT ➔ RAGE ➔ RETALIATION ➔ POLICE PURSUIT ➔ DELIVERY ➔ SCORE
```

1. **American Long-Nose Semi-Truck & High-Detail Trailer:**
   - Detailed cab hood, grille, chrome bumper, windshield, dual exhaust stacks, mirrors, fuel tanks, and headlights.
   - **High-detail trailer rear**: twin swinging split doors, 4 vertical galvanized locking bars with cam keepers and grab handles, 8 hinges, alternating Red/White DOT Conspicuity reflective tape, upper white corner markers, triple red ID clearance cluster, heavy ICC underride bumper, recessed brake/turn lights, chevron mudflaps, and tandem dual wheels.
   - 105 MPH top speed with diesel torque, speed-sensitive steering inertia, air brakes, and realistic trailer articulation.
2. **Interactive 3D Showroom Garage:**
   - **REDLINE:** Crimson Red with polished chrome stacks.
   - **BLUE THUNDER:** Electric Blue with neon cyan trim.
   - **NIGHT RIDER:** Midnight Black with stealth gunmetal plating.
3. **Daytime Open Highway Environment Engine:**
   - Vibrant daytime lighting with bright cyan-blue sky, natural sunlight, sandy gravel shoulders, and wide green grass embankments.
   - Rolling voxel canyon hills along horizons with sandstone strata and stepped grass caps.
   - Wooden utility poles with crossbars every 42m, roadside pine trees, shrubs, Jersey barriers, and cantilever overpass bridges.
4. **8 High-Detail Traffic Vehicles:**
   - Compact Sedan, Sports Sedan, Full-Size SUV, Heavy Pickup Truck, Exotic Supercar, Commercial Delivery Van, Civilian Semi-Truck, and Highway Patrol Cruiser.
   - Aggressive drivers cut into your lane and brake-check with floating `⚠ BRAKE!` warnings.
5. **Vehicle Physical Collisions & Four-Hit Arcade Damage:**
   - Semi-truck maintains heavy momentum, pushing smaller vehicles forward and sideways based on collision impulse.
   - **Hit 1**: Push response + shower of sparks.
   - **Hit 2**: Stronger push + permanent chassis crumple tilt + white hood smoke.
   - **Hit 3**: Violent push + spin/skid-out + thick billowing black smoke and embers.
   - **Hit 4**: Vehicle breaks apart into 36+ bouncing voxel debris chunks with ground bounce physics.
6. **5-Tier Road Rage & Retaliation Combat:**
   - Calm ➔ Annoyed ➔ Furious ➔ Critical ➔ **RETALIATION READY**.
   - Press `SPACE` to deploy dual machine-gun turrets with raycast-assisted 3D trajectory aiming directly at enemy vehicles at 185 m/s.
   - Instrumental Soft Rock cruising audio crossfades dynamically to high-energy Heavy Metal during Retaliation.
7. **5-Star Police Heat & Pursuit AI:**
   - Escalating heat draws black-and-white pursuit cruisers with alternating red/blue lightbars and sirens attempting PIT maneuvers.
8. **Physical Warehouse Delivery & Multi-Contract Loop:**
   - Deliver cargo to **Riverside Logistics Center**; animated roll-up door lifts on approach and seals behind trailer inside bay.
   - Victory rank calculation (S to D) and progression into Contract Round 2 ("METRO CONTAINER SHIFT").

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
