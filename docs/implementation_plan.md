# VOXEL HAULER: ASPHALT RETALIATION
## Master Implementation Plan — Version 1.0

### Executive Overview
"Voxel Hauler: Asphalt Retaliation" is a high-octane 3D arcade trucking game built on Godot 4.7. The player pilots a heavy-duty American semi-truck delivering vital industrial cargo through dense, aggressive highway traffic. When frustrated by reckless drivers, dangerous mergers, and deliberate brake-checks, the player builds Road Rage until reaching 100%, unlocking RETALIATION MODE: deploying dual cab-mounted arcade machine-gun turrets to blast obstructing traffic into voxel debris. Reckless driving and combat escalate Police Heat (0–5 stars), drawing aggressive highway patrol pursuit cruisers.

---

### Phase Breakdown

#### Phase 1: Project Setup, Garage & Core Driving Physics
- **Objective:** Establish the Godot 4 project architecture, persistent truck customization garage, 3D voxel vehicle geometry, camera systems, and responsive physics-driven arcade driving.
- **Key Deliverables:**
  - `project.godot` configured with custom input maps, 3D render pipeline, and window sizing.
  - Voxel truck and trailer models built with modular meshes: cab, chrome grille, dual exhaust stacks, 10 heavy wheels, articulated trailer, and concealed dual turret compartments.
  - 3 truck presets:
    1. **REDLINE** — Crimson Red (`#C41E3A`) with polished chrome accents.
    2. **BLUE THUNDER** — Electric Blue (`#0077BE`) with cyan neon touches.
    3. **NIGHT RIDER** — Midnight Black (`#1A1A1A`) with matte gunmetal trims.
  - Interactive 3D Garage: turntable rotation, color variant selection, persistent save/load via `user://save_data.json`, and direct launch into delivery.
  - Arcade Truck Physics (`truck_controller.gd`): responsive acceleration (0–105 MPH), turning inertia, weight shifting, realistic braking distance, and trailer articulation.
  - Third-Person Chase Camera (`chase_camera.gd`): distance toggle (`C`), camera lag, look-ahead, speed FOV scaling, and trauma shake.

#### Phase 2: Highway Environment, AI Traffic, Delivery & Damage
- **Objective:** Construct a complete 4-lane highway route, lively multi-class traffic simulation, delivery route GPS, and realistic truck/cargo integrity tracking.
- **Key Deliverables:**
  - Highway corridor (`highway.tscn`): 4-to-6 lane roadway, textured asphalt, concrete barriers, overhead gantries, Exit 42B interchange, bridges, streetlights, city skyline backdrop, and sunset/golden hour lighting.
  - First Playable Mission: "CITY FREIGHT RUN" (West Freight Depot to Riverside Logistics Center, 5-minute delivery window).
  - Multi-Class AI Traffic (`traffic_manager.gd`, `traffic_vehicle.gd`):
    - Vehicle classes: Sedans, SUVs, Pickup Trucks, Sports Cars, Delivery Vans, Semi-Trucks.
    - AI states: `CRUISING`, `FOLLOWING`, `LANE_CHANGING`, `MERGING`, `BRAKE_CHECKING`, `BLOCKING`, `EVADING`, `DAMAGED`, `DISABLED`, `DESTROYED`.
    - Offender alert: Visual 3D floating "BRAKE" warning sign above aggressive brake-checking vehicles.
  - Dedicated GPS System (`gps_system.gd`): upper-left display, miniature road map, blue route ribbon, distance-to-maneuver countdown, next exit callouts, and large roadway yellow exit arrows for Exit 42B.
  - Independent Integrity Systems: Truck Integrity (0–100%) and Cargo Integrity (0–100%) with collision physics and damage calculation.

#### Phase 3: Road Rage & Dual-Turret Retaliation Combat
- **Objective:** Implement the dynamic Road Rage meter, turret deployment animation, target acquisition HUD, arcade projectile combat, and voxel destruction.
- **Key Deliverables:**
  - Road Rage System (`rage_system.gd`):
    - Tiers: 0–24% Calm, 25–49% Annoyed, 50–74% Furious, 75–99% Critical, 100% RETALIATION READY.
    - Accumulation from close calls, brake-checks, collisions, and blocking.
    - Audio alerts, camera trauma, and prominent bottom HUD banner: "RETALIATION READY — PRESS SPACE".
  - Retaliation Mode (`turret_system.gd`):
    - 12-second active duration with widening camera FOV and red alert banner.
    - Animated turret hatch doors opening and dual machine gun pods rising from the cab roof.
    - Target targeting brackets (`TAB` to cycle targets, automatic nearest target lock-on).
    - Left-click arcade dual projectile fire, muzzle flashes, ballistic tracer visuals, and high fire rate.
    - Enemy damage model: spark particles, smoke, structural voxel breakage, and explosive vehicular detonation.

#### Phase 4: Police Heat & Pursuit AI
- **Objective:** Create a dynamic 5-star Police Heat hierarchy with autonomous patrol pursuit units.
- **Key Deliverables:**
  - 5-Star Heat Hierarchy (`police_manager.gd`):
    - 0 Stars: Calm
    - 1 Star: Watched
    - 2 Stars: Searching
    - 3 Stars: Pursuit (Patrol Cruisers dispatched)
    - 4 Stars: Interceptors (Aggressive tactical cruisers)
    - 5 Stars: Lockdown (Multiple interceptors, heavy roadblocks)
  - Heat accumulation from aggressive collisions, traffic destruction, and combat in view of authorities. Natural heat decay when driving cleanly out of sight.
  - Police Pursuit Cruiser AI (`police_cruiser.gd`):
    - Voxel black-and-white police cruisers with active alternating red/blue lightbars and siren audio.
    - Pursuit behaviors: overtaking, PIT maneuver attempts, flanking, and roadblock boxing.
    - Capture condition if the player is boxed in and brought to a standstill.

#### Phase 5: UI/UX Hierarchy, Audio, Effects & Scoring
- **Objective:** Complete the UI layout strictly matching the reference screenshots, rich procedural sound effects, particle systems, mission scoring, and automated verification.
- **Key Deliverables:**
  - Screen hierarchy: Main Menu, Truck Garage, Pause Menu, Results Screen.
  - In-Game HUD:
    - Upper Left: GPS Minimap, Route progress, Exit instructions, Delivery countdown.
    - Upper Right: Police Heat (5 interactive stars + status label).
    - Lower Center: Large digital MPH readout, Gear indicator, RPM bar, Truck condition %, Cargo integrity %.
    - Bottom Edge: Full-width Road Rage meter with dynamic color gradients and pulsing ready state.
  - Scoring & Grading System: Delivery time, cargo preservation, truck durability, clean driving bonus, retaliation combat bonus, police evasion penalty; letter grades S, A, B, C, D.
  - Sound Effects: Synthesized procedural audio for diesel engine RPM, air brakes, tire squeal, horn, collisions, rage charge, turret fire, explosions, and sirens.
  - Particle Systems: Voxel debris bursting, fire/smoke emitters, exhaust stacks smoke, tire burnouts.
  - Automated headless test suite (`test_runner.gd`) to validate game state transitions, physics, combat, AI, and mission logic.
