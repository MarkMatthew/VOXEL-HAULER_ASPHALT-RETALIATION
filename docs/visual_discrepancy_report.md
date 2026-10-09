# VOXEL HAULER: Visual Discrepancy Report — V1.0 vs V1.1 Target

## Purpose
This document audits the visual and gameplay discrepancies between the baseline version (V1.0) and the original four-panel arcade concept artwork (V1.1 Target). It identifies every specific area requiring enhancement and defines the architectural solution for each.

---

### Discrepancy Analysis

#### 1. Semi-Truck & Trailer Fidelity
- **Baseline Discrepancy:** The initial truck model comprised basic monolithic cuboids with flat shading, lacking the intricate details that define a classic American heavy-duty semi-truck (mirrors, visor, detailed grille slats, exhaust heat shields, rear trailer doors, mudflaps, and proper tire rims).
- **Target Resolution:** Full procedural voxel reconstruction adding layered geometric components: chrome-slatted vertical front grille, hood ornament center rib, aerodynamic cab roof visor, amber roof clearance lights, dual vertical exhaust stacks with heat shields, side-view mirrors, cylindrical fuel tanks with mounting steps, 10 detailed wheels with rubber tires and chrome lug nuts, and a corrugated 53ft dry van trailer with rear swinging doors, hinges, and mudflaps.

#### 2. Garage Showroom Presentation & Framing
- **Baseline Discrepancy:** The garage displayed the truck on an untextured circle with a camera angle positioned too close, causing parts of the cab and trailer to be clipped by the viewport boundaries.
- **Target Resolution:** Construct an industrial warehouse showroom interior with high-bay ceiling trusses, polished reflective concrete flooring, overhead warm spotlights with soft shadow mapping, and a carefully framed 3/4 isometric camera angle situated ~18m away, ensuring the full length of the 53ft trailer and long-nose cab are showcased with zero clipping.

#### 3. Gameplay Camera Perspective
- **Baseline Discrepancy:** The chase camera was positioned low behind the trailer roof, occluding the driver's forward visibility of oncoming traffic lanes, overhead gantry signs, and distant exits.
- **Target Resolution:** Elevate the chase camera rig to an elevated high-angle perspective (~14m elevation above road grade, ~24m trailing distance, ~25° downward pitch), positioning the truck in the lower third of the viewport so that over 70% of the screen area is dedicated to four lanes of forward traffic, approaching exit ramps, and roadside hazards. Support 3 selectable camera presets (`C` key).

#### 4. Environment Detail & City Skyline
- **Baseline Discrepancy:** Highway borders were populated with sparse, uniform cubes without windows, signage, overpasses, or foliage, creating a flat, artificial environment.
- **Target Resolution:** Rebuild the highway corridor with textured asphalt, rumble strip margins, concrete Jersey barriers, steel guardrails, dual-deck overpass bridges, overhead steel gantries with green destination signs, roadside voxel pine trees, and a skyline featuring skyscraper towers with illuminated window grids, industrial depots, and warehouse complexes.

#### 5. Dynamic Time-of-Day System
- **Baseline Discrepancy:** The environment relied on a static single-phase sunset light with fixed sky colors.
- **Target Resolution:** Implement a dynamic, continuous Time-of-Day Engine progressing through:
  - **Daytime:** Crisp blue sky, bright natural sunlight, clear visibility, sharp building facades.
  - **Late Afternoon / Sunset:** Golden-hour orange and pink atmospheric haze, long dramatic shadows, warm building reflections.
  - **Evening / Night:** Deep indigo sky, illuminated skyscraper office windows, activated sodium streetlights, working vehicle headlights and taillights, vibrant muzzle flashes and explosion illumination.

#### 6. AI Traffic Vehicles
- **Baseline Discrepancy:** Traffic consisted only of colored boxes with rudimentary wheels.
- **Target Resolution:** Build 8 distinct voxel vehicle types: Compact Sedan, Sports Sedan, SUV, Pickup Truck, Sports Car, Delivery Van, Civilian Semi-Truck, and Police Cruiser. Each vehicle features custom wheel arches, bumpers, tinted windows, windshields, headlights, taillights, and distinct color palettes.

#### 7. In-World Warning System & HUD Hierarchy
- **Baseline Discrepancy:** Floating warnings were limited to a single brake text label; HUD panels were separated but lacked arcade polish.
- **Target Resolution:** Rebuild the HUD with high-contrast arcade panels (GPS upper-left, Police Heat upper-right, Digital speedometer cluster lower-center, segmented Rage meter bottom). Implement prominent contextual 3D floating billboard signs for `BRAKE!`, `DANGEROUS MERGE`, `COLLISION`, `EXIT APPROACHING`, `WRONG WAY`, and `RETALIATION READY`.

#### 8. Dynamic Music Engine
- **Baseline Discrepancy:** Only basic sound effects were present; no dynamic background music existed.
- **Target Resolution:** Implement an interactive dual-genre Music Director:
  - **Cruising Mode:** Instrumental Soft Rock (105 BPM) with clean guitar, melodic bass, and steady drums.
  - **Retaliation Mode:** Instrumental Heavy Metal (155 BPM) with driving double-kick drums and heavy distorted guitar riffs.
  - Seamless crossfading during Retaliation activation and expiration, volume ducking on warehouse approach, and victory fanfare.

#### 9. Physical Warehouse Delivery Sequence
- **Baseline Discrepancy:** Delivery finished instantly upon contacting a simple trigger box on the roadway.
- **Target Resolution:** Implement a 5-step interactive delivery sequence inside a physical warehouse:
  1. GPS prompts `DESTINATION APPROACHING` and guides into delivery lane.
  2. Large industrial roll-up door animates open vertically on approach.
  3. Player drives truck and trailer inside the lit warehouse interior (concrete floor, trusses, pallets, shelving, marked bay).
  4. Entrance door animates closed behind the truck once the trailer rear clears the threshold.
  5. Mission ends with final scoring calculation and the ability to launch Contract Round 2.
