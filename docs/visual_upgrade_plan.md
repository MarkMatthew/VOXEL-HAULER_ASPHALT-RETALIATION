# VOXEL HAULER: ASPHALT RETALIATION
## Master Visual & Gameplay Upgrade Plan — Version 1.1

### Executive Summary
This document specifies the technical architecture, visual overhaul, audio engine, and warehouse delivery system for **Voxel Hauler: Asphalt Retaliation (V1.1)**. The objective is to elevate the existing baseline into a rich retro-modern 3D voxel arcade experience matching the four-panel gameplay concept art, while preserving all core mechanics, driving feel, physics, combat logic, and deployment workflows (Godot engine and live Vercel web deployment).

---

### Baseline Assessment vs. Target Visual Fidelity

| System | Baseline (V1.0) | Target (V1.1 Master Upgrade) |
| :--- | :--- | :--- |
| **Semi-Truck** | Simplified blocky cab and trailer primitives | Detailed American long-nose hauler: prominent chrome grille, detailed visor, side mirrors, dual tall exhaust stacks, fuel tanks, 5 axles with detailed rims/rubber tires, 53ft dry van trailer with corrugated ribs, rear cargo doors, hinges, mudflaps, and roof turret hatches. |
| **Garage Showroom** | Basic turntable pedestal | Illuminated industrial warehouse showroom with polished concrete reflections, overhead spotlight trusses, soft studio shadows, and framed 3/4 isometric camera angle without clipping. |
| **Gameplay Camera** | Low chase camera focusing mostly on trailer | Elevated high-angle chase camera (~14m height, ~24m distance, ~25° downward pitch) framing the truck in the lower third and dedicating the majority of the screen to approaching multi-lane traffic, exits, and hazards. Includes 3 toggleable presets (Elevated, Standard, Highway Overview). |
| **Highway Environment** | Uniform asphalt strip with basic cube backdrop | 4–6 lane highway corridor with asphalt surface variation, crisp road striping, Jersey barriers, steel guardrails, overpass highway bridges, overhead gantries with green exit signage, roadside trees, industrial warehouses with loading docks, and downtown skyline with lit window grids and architectural silhouettes. |
| **Lighting & Atmosphere** | Static sunset DirectionalLight | Dynamic Time-of-Day Engine transitioning continuously across Daytime, Late Afternoon / Sunset, and Evening / Night with synchronized sun color/elevation, ambient skylight, fog, dynamic streetlights, illuminated building windows, and vehicle headlights. |
| **AI Traffic Vehicles** | Basic colored boxes with wheels | 8 distinct recognizable voxel vehicle types: Compact Sedan, Sports Sedan, SUV, Pickup Truck, Sports Car, Delivery Van, Civilian Semi-Truck, and Police Interceptors. Detailed with grilles, windshields, headlights, taillights, bumpers, and proper scaling. |
| **HUD & Warning System** | Basic instrumentation overlay | High-contrast arcade HUD hierarchy matching reference: top-left GPS with live minimap ribbon and route progress; top-right 5-star Police Heat; lower-center high-visibility digital MPH cluster with gear, RPM, and dual integrity gauges; bottom segmented Rage meter with pulsing Retaliation state; contextual in-world billboard warning markers (`BRAKE!`, `DANGEROUS MERGE`, `COLLISION`, `EXIT APPROACHING`, `RETALIATION READY`). |
| **Music System** | Sound effects only | Dynamic Multi-Track Music Director: Instrumental Soft Rock (95–110 BPM, clean guitars, relaxed rhythm) during normal cruising, crossfading seamlessly into Instrumental Heavy Metal (150–165 BPM, driving double-kick drums, distorted riffs) during Retaliation Mode, with warehouse arrival damping and victory/failure stingers. |
| **Delivery Completion** | Simple trigger area box | Full physical warehouse delivery sequence: GPS prompts `DESTINATION APPROACHING`, guidance into approach lane, physical warehouse bay doors animate open, truck drives inside complete interior (concrete floor, overhead industrial trusses, pallets, shelving, marked bay), door closes visibly behind the trailer once fully cleared, delivery completion screen with rank, and Option to start Contract Round 2. |

---

### Phased Implementation Roadmap

#### Phase A — Semi-Truck & Showroom Garage Rebuild
- Construct high-detail American long-nose semi-truck cab and 53ft articulated dry van trailer with all required architectural components.
- Maintain shared geometry with 3 cosmetic presets:
  - **REDLINE:** Crimson Red (`#C41E3A`) cab with polished chrome grille and mirror stacks.
  - **BLUE THUNDER:** Electric Blue (`#0077BE`) cab with neon cyan accents.
  - **NIGHT RIDER:** Midnight Black (`#161618`) cab with stealth gunmetal plating.
- Overhaul Showroom Garage with industrial concrete flooring, spotlight trusses, soft shadows, specifications card, and camera framing ensuring the entire rig is visible without clipping.

#### Phase B — Highway Corridor & Multi-Class Traffic
- Build 4–6 lane modular highway system with asphalt textures, rumble strips, concrete barriers, highway bridges, overhead gantries, and roadside trees.
- Populate skyline with architectural variety: multistory office towers, window grids, industrial depots, and warehouses.
- Construct 8 distinct traffic vehicle models with distinct dimensions, colors, and lighting.

#### Phase C — Elevated Chase Camera & In-World Warning System
- Reconfigure camera to elevated high-angle perspective (~14m height, ~24m distance, ~25° downward pitch) giving clear forward view over trailer roof.
- Implement camera presets switchable via `C` key (Elevated Chase, Standard Chase, Highway Overview).
- Implement contextual in-world 3D billboard warnings (`BRAKE!`, `DANGEROUS MERGE`, `COLLISION`, `EXIT APPROACHING`, `RETALIATION READY`).

#### Phase D — Dynamic Time-of-Day Engine
- Implement continuous daylight engine cycling through Daytime (14:00), Late Afternoon/Sunset (17:00), and Evening/Night (20:00).
- Dynamically interpolate sun direction, sun color, sky gradient, ambient illumination, and fog density.
- Automatically activate streetlights, skyscraper window illumination, vehicle headlights, and taillights as darkness falls.
- Add developer preview hotkeys (`1`: Day, `2`: Sunset, `3`: Night).

#### Phase E — Dynamic Music Director
- Implement Web Audio and procedural multi-track music synthesizer engine:
  - Track 1: Instrumental Soft Rock cruising groove (clean guitars, bassline, laid-back drums).
  - Track 2: High-energy Heavy Metal combat track (driving double-kick drums, heavy distorted guitar riffs).
- Implement smooth crossfading transitions (0.5–1.2s upon Retaliation activation, 2–3s upon expiration).
- Add audio controls (Master, Music, SFX volume) with local persistence.

#### Phase F — Warehouse Delivery Sequence & Next Round Contract
- Build full 3D Logistics Terminal exterior and interior at destination:
  - Exterior: approach lane, safety striping, overhead floodlights, roll-up industrial warehouse door.
  - Interior: concrete floor, steel truss ceiling, warehouse shelving, stacked wooden pallets, marked parking zone.
- Implement 5-step delivery state machine:
  1. GPS switch to local terminal approach (`DESTINATION APPROACHING`).
  2. Warehouse door physically animates open on truck approach.
  3. Player drives full semi-truck and trailer through the entrance.
  4. Door closes once trailer rear clears entrance bounding box.
  5. Delivery completion scoring and contract victory fanfare.
- Support **Contract Round 2**: Player can select "START NEXT CONTRACT" to load a second distinct delivery contract preserving truck selection and advancing world time-of-day.

#### Phase G — Retaliation Combat & Visual Effects Overhaul
- Animated turret deployment with mechanical hatch panels.
- Arcade target lock-on brackets in 3D space with `TAB` target cycling.
- High-velocity twin energy tracers with muzzle flash lighting.
- Exploding vehicles fragment into 22+ voxel debris chunks with physics gravity and ground bounces.

#### Phase H — Testing, QA & Vercel Deployment
- Execute headless and browser integration test suites.
- Perform visual regression checks across day/night cycles and camera presets.
- Push clean commits to GitHub (`MarkMatthew/VOXEL-HAULER_ASPHALT-RETALIATION`) and verify Vercel live production deployment.
