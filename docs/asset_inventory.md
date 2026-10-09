# VOXEL HAULER: Asset Inventory & Manifest — V1.1

## Overview
This manifest catalogues all 3D geometry, materials, textures, shaders, procedural sound effects, and musical tracks utilized across both the native Godot engine implementation and the production WebGL / Vercel deployment.

---

### 1. 3D Vehicle Geometry Manifest

| Asset Name | Target File / Class | Category | Generation Method | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Long-Nose Semi Cab** | `src/world/voxel_mesh_builder.gd`, `public/index.html` | Player Vehicle | Procedural Voxel Builder | Final | Hood, grille, bumper, windshield, sleeper cab, visor, dual exhaust stacks, fuel tanks, mirrors, 6 wheels, turret hatches. |
| **53ft Dry Van Trailer** | `src/world/voxel_mesh_builder.gd`, `public/index.html` | Player Vehicle | Procedural Voxel Builder | Final | Corrugated aluminum sidewalls, kingpin hitch, dual rear axles, mudflaps, hazard bumper, opening rear doors. |
| **Retaliation Turret Pods** | `src/player/turret_system.gd`, `public/index.html` | Combat | Procedural Voxel Builder | Final | Dual machine-gun barrels, ammo feeder, swiveling base, animated deployment elevation. |
| **Compact Sedan** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | 4-door family civilian car with headlights and taillights. |
| **Sports Sedan** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | Aerodynamic 4-door performance sedan. |
| **Voxel SUV** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | Chunky full-size SUV with roof luggage rails and rear spare. |
| **Pickup Truck** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | Dual-cab pickup truck with open rear cargo bed. |
| **Sports Car** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | Low-slung supercar with rear aerodynamic wing spoiler. |
| **Delivery Van** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | High-roof commercial parcel delivery van. |
| **Civilian Semi-Truck** | `src/traffic/traffic_vehicle.gd`, `public/index.html` | AI Traffic | Procedural Voxel Builder | Final | Heavy hauler with container chassis. |
| **Police Cruiser** | `src/police/police_cruiser.gd`, `public/index.html` | Law Enforcement | Procedural Voxel Builder | Final | Black-and-white highway patrol cruiser with push bumper and flashing emergency lightbar. |

---

### 2. Environment & Architectural Geometry Manifest

| Asset Name | Target File / Class | Category | Generation Method | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **4-Lane Highway Roadbed** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Mesh | Final | Textured asphalt, lane divisions, rumble strips, road chevrons. |
| **Exit 42B Interchange Ramp** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Mesh | Final | Diverging off-ramp with illuminated yellow chevron arrows. |
| **Concrete Jersey Barriers** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Mesh | Final | Beveled safety barrier separating lanes and shoulders. |
| **Highway Overpass Bridge** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Mesh | Final | Dual-deck overpass spans above roadway. |
| **Overhead Highway Gantries** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Mesh | Final | Steel truss frame with green Interstate destination signage. |
| **Highway Light Poles** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Mesh | Final | Steel light poles with dynamic night illumination. |
| **Roadside Trees & Foliage** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Voxel Builder | Final | Stylized pine and oak voxel trees flanking highway. |
| **Downtown Office Towers** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Voxel Builder | Final | Multistory skyscrapers with emissive window grids. |
| **Industrial Distribution Depot** | `src/world/highway.gd`, `public/index.html` | Environment | Procedural Voxel Builder | Final | Metal-clad warehouses with loading bays. |
| **Riverside Logistics Warehouse** | `src/world/highway.gd`, `public/index.html` | Mission Goal | Procedural Voxel Builder | Final | Complete exterior & interior: animated roll-up door, steel trusses, shelving, pallets, parking bay. |

---

### 3. Audio & Music Manifest

| Asset Name | File Path / Synthesizer | Category | Format / Spec | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Soft Rock Cruising Track** | Web Audio Music Synthesizer / Audio Director | Music | Procedural Interactive Audio (105 BPM) | Final | Clean electric guitar, rhythmic drums, melodic bass. |
| **Heavy Metal Retaliation Track** | Web Audio Music Synthesizer / Audio Director | Music | Procedural Interactive Audio (155 BPM) | Final | Distorted lead riffs, driving double-kick drums, heavy bass. |
| **Delivery Completion Fanfare** | Web Audio / `assets/audio/victory.wav` | SFX / Music | 16-bit 44.1kHz WAV | Final | Brass orchestral fanfare on warehouse entry. |
| **Mission Defeat / Busted Stinger**| Web Audio / `assets/audio/defeat.wav` | SFX / Music | 16-bit 44.1kHz WAV | Final | Somber descending progression. |
| **Diesel Engine RPM Loop** | Web Audio / `assets/audio/engine_loop.wav` | SFX | 16-bit 44.1kHz WAV | Final | Multi-harmonic diesel combustion with speed pitch scaling. |
| **Pneumatic Air Brake Hiss** | Web Audio / `assets/audio/air_brake.wav` | SFX | 16-bit 44.1kHz WAV | Final | High-pressure air release discharge. |
| **Dual Air Horn Blast** | Web Audio / `assets/audio/horn.wav` | SFX | 16-bit 44.1kHz WAV | Final | Dual-chime 220Hz/277Hz semi horn. |
| **Tire Drift / Squeal** | Web Audio / `assets/audio/tire_squeal.wav` | SFX | 16-bit 44.1kHz WAV | Final | Frequency-modulated asphalt scrub. |
| **Metal Collision Crunch** | Web Audio / `assets/audio/collision.wav` | SFX | 16-bit 44.1kHz WAV | Final | Low boom and crunch transient. |
| **Rage Tier Warning Chime** | Web Audio / `assets/audio/rage_alert.wav` | SFX | 16-bit 44.1kHz WAV | Final | Rising tension chime. |
| **Retaliation Ready Powerup** | Web Audio / `assets/audio/retaliation_ready.wav` | SFX | 16-bit 44.1kHz WAV | Final | Upward synth sweep riser. |
| **Turret Servo Deployment** | Web Audio / `assets/audio/turret_deploy.wav` | SFX | 16-bit 44.1kHz WAV | Final | Mechanical servo motor and hatch latch. |
| **Twin Arcade Machine Gun** | Web Audio / `assets/audio/machine_gun.wav` | SFX | 16-bit 44.1kHz WAV | Final | Punchy twin-barrel projectile shot. |
| **Voxel Shatter Explosion** | Web Audio / `assets/audio/explosion.wav` | SFX | 16-bit 44.1kHz WAV | Final | Sub-bass detonation with fragment impact. |
| **Police Pursuit Siren** | Web Audio / `assets/audio/police_siren.wav` | SFX | 16-bit 44.1kHz WAV | Final | Wailing two-tone emergency siren. |
