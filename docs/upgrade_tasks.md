# VOXEL HAULER: V1.1 Upgrade Task Tracking Matrix

## Phase A: Semi-Truck & Showroom Garage Rebuild
- [x] A.1 Rebuild long-nose American semi-truck cab with high-detail voxel geometry (hood, grille, visor, dual exhaust, mirrors, fuel tanks, 6 wheels, turret hatches).
- [x] A.2 Rebuild 53ft dry van trailer with corrugated ribs, kingpin hitch, dual rear axles, mudflaps, rear doors, and hazard bumper.
- [x] A.3 Maintain shared geometry across the 3 color variants (REDLINE, BLUE THUNDER, NIGHT RIDER).
- [x] A.4 Overhaul Truck Garage into an illuminated industrial showroom with concrete floor, overhead lights, soft shadows, and non-clipping 3/4 framing.

## Phase B: Highway Corridor & Multi-Class Traffic
- [x] B.1 Rebuild modular 4–6 lane highway with textured asphalt, rumble strips, Jersey barriers, and guardrails.
- [x] B.2 Construct highway infrastructure: dual-deck overpass bridges, Exit 42B interchange, overhead gantries, and streetlights.
- [x] B.3 Add roadside pine trees and varied city skyline with lit office window grids and industrial warehouses.
- [x] B.4 Construct 8 high-detail traffic models (Compact Sedan, Sports Sedan, SUV, Pickup Truck, Sports Car, Delivery Van, Semi-Truck, Police Cruiser).

## Phase C: Elevated Chase Camera & In-World Warnings
- [x] C.1 Reconfigure primary gameplay camera to elevated chase perspective (~14m height, ~24m distance, ~25° downward pitch).
- [x] C.2 Implement 3 camera presets switchable via `C` key (Elevated Chase, Standard Chase, Highway Overview).
- [x] C.3 Build contextual in-world 3D billboard warnings (`BRAKE!`, `DANGEROUS MERGE`, `COLLISION`, `EXIT APPROACHING`, `RETALIATION READY`).

## Phase D: Dynamic Time-of-Day Engine
- [x] D.1 Implement continuous world clock and lighting interpolation across Daytime, Late Afternoon / Sunset, and Evening / Night.
- [x] D.2 Synchronize sun elevation, directional color, ambient light, fog, and exposure.
- [x] D.3 Implement dynamic nighttime illumination: building window lights, streetlights, vehicle headlights, and taillights.
- [x] D.4 Add developer preview hotkeys (`1` = Day, `2` = Sunset, `3` = Night).

## Phase E: Dynamic Music Director
- [x] E.1 Implement Web Audio interactive multi-track music engine.
- [x] E.2 Compose / generate Instrumental Soft Rock cruising track (clean guitar, relaxed rhythm, 105 BPM).
- [x] E.3 Compose / generate Instrumental Heavy Metal combat track (distorted guitars, double-kick drums, 155 BPM).
- [x] E.4 Implement crossfading transitions for Retaliation activation/expiration and warehouse arrival.
- [x] E.5 Add volume controls for Master, Music, and SFX with local persistence.

## Phase F: Physical Warehouse Delivery Sequence
- [x] F.1 Construct Riverside Logistics Center exterior and interior at destination (roll-up door, steel trusses, shelving, pallets, marked bay).
- [x] F.2 Implement arrival state machine: approach announcement (`DESTINATION APPROACHING`) and lane guidance.
- [x] F.3 Implement physical animated warehouse roll-up door opening on truck approach.
- [x] F.4 Implement interior driving zone with full clearance for cab and trailer.
- [x] F.5 Implement trailer rear bounding clearance check to close warehouse door behind truck.
- [x] F.6 Stop timer, calculate delivery results, and display victory panel with rank S–D.
- [x] F.7 Implement Contract Round 2 ("START NEXT CONTRACT") with distinct route parameters and advancing time-of-day.

## Phase G: Retaliation Combat & Visual Effects Overhaul
- [x] G.1 Upgrade turret deployment animations, twin-barrel machine guns, and muzzle flash point lights.
- [x] G.2 Implement 3D arcade target lock-on reticle with `TAB` target cycling.
- [x] G.3 Enhance projectile tracers, spark bursts, vehicle smoke, and 22+ fragment voxel debris explosions with ground bounce.
- [x] G.4 Enhance police pursuit sirens, flashing lightbars, and ramming tactics.

## Phase H: QA, Testing & Vercel Deployment
- [x] H.1 Execute automated test suite verifying all upgraded systems, scenes, and mechanics.
- [x] H.2 Verify cross-browser performance at 60 FPS in WebGL.
- [x] H.3 Commit changes to git and push to GitHub repository (`MarkMatthew/VOXEL-HAULER_ASPHALT-RETALIATION`).
- [x] H.4 Verify live production build on Vercel.

## Phase I: V1.2 Executive Build Directive — Visual Quality & Vehicle Collision Upgrade
- [x] I.1 **Rear Trailer Detail Rebuild**:
  - Twin swinging doors with recessed weatherstripping center seam.
  - 4 heavy vertical galvanized locking bars with top/bottom cam keepers and horizontal handles.
  - 8 outer cast-steel hinges along the outer door frame.
  - Alternating Red/White DOT Conspicuity reflective safety tape across lower doors and bumper face.
  - Top white inverted-L corner markers and triple red ID clearance cluster.
  - Heavy ICC underride protection guard bumper with vertical steel struts.
  - Recessed rear lighting cluster (intense red brake/tail lights + amber turn signals) and license plate.
  - Heavy rubber mudflaps with white hazard chevrons and dual tandem wheels.
- [x] I.2 **8 High-Detail Traffic Vehicles**:
  - Rebuilt Compact Sedan (hood, cabin, trunk, roof).
  - Rebuilt Sports Sedan (aggressive wedge nose, quad headlights, rear spoiler, dual exhaust).
  - Rebuilt Full-Size SUV (boxy silhouette, roof rack rails, rear-mounted spare tire).
  - Rebuilt Heavy Pickup Truck (crew cab, open cargo bed, tubular chrome rollbar with off-road lights).
  - Rebuilt Exotic Supercar (ultra-low slung, cockpit canopy, aggressive rear diffuser, high-mounted wing).
  - Rebuilt Commercial Delivery Van (tall cargo body, rear swinging doors, side rub strips).
  - Rebuilt Civilian Semi-Truck (cab-over-engine, sleeper roof fairing, vertical exhaust, tanker trailer).
  - Rebuilt Highway Patrol Cruiser (black-and-white pursuit livery, push-bumper, animated red/blue LED lightbar).
- [x] I.3 **Daytime Open Highway Environment**:
  - Pure vibrant daytime setting with natural sun illumination (`0xfffaec`, intensity 2.3), clear cyan-blue sky (`0x5dade2`), and clean atmosphere.
  - Multi-tier rolling voxel canyon hills along both horizons with stratified sandstone and green grass terraces.
  - Sandy gravel roadside shoulders and wide green grass embankments.
  - Wooden utility poles with crossbars and transformers placed every 42m.
  - Roadside pine trees, shrubs, concrete barriers, and cantilever highway overpasses.
- [x] I.4 **Vehicle Physical Collisions & Four-Hit Arcade Damage**:
  - Momentum-preserving collision push response shoves smaller cars forward and sideways based on impact velocity and direction.
  - 0.42s collision cooldown prevents single-contact instant destruction.
  - Hit 1: Vehicle pushed with physical impulse + shower of metallic sparks.
  - Hit 2: Stronger push + permanent chassis crumple tilt + continuous white hood smoke.
  - Hit 3: Violent push + loss of traction spin + thick billowing black smoke and burning embers.
  - Hit 4: Vehicle breaks apart into 36+ bouncing voxel debris chunks with ground physics.
- [x] I.5 **Turret Trajectory & Raycast Hit System**:
  - Raycast-guided 3D aim trajectory directly targeting enemy vehicle core (`Y=0.65`) at 185 m/s, preventing projectiles from flying overhead.
  - Integrated with Four-Hit damage system (Stage 1 / Stage 2 turret hit thresholds).
- [x] I.6 **Visual QA Verification & Headless Screenshots**:
  - Automated visual inspection harness (`?test=trailer`, `?test=traffic`, `?test=damage`, `?test=garage`, `?autostart=1`).
  - Captured high-resolution verification screenshots stored in `docs/screenshots/`.

