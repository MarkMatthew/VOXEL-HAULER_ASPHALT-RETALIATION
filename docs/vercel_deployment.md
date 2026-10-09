# Deploying VOXEL HAULER to Vercel

## Overview
**Yes, you can run VOXEL HAULER on Vercel!**

Vercel is a global edge and static web hosting platform. To run 3D games on Vercel, the game must run in modern web browsers via WebGL / WebAssembly. 

Everything needed to deploy and run **VOXEL HAULER: ASPHALT RETALIATION** on Vercel is already pre-configured in this repository.

---

## What Has Been Pre-Configured

1. **`vercel.json`**
   - Configured with the mandatory `Cross-Origin-Opener-Policy: same-origin` (COOP) and `Cross-Origin-Embedder-Policy: require-corp` (COEP) headers.
   - These headers are strictly required by Chrome, Safari, Edge, and Firefox for browser games that utilize WebAssembly, high-precision performance timers, and `SharedArrayBuffer` audio streaming.

2. **Zero-Config Web Edition (`public/index.html` and root `index.html`)**
   - A fully playable 3D WebGL edition reproducing the complete game:
     - 3 Selectable Voxel Trucks in the 3D rotating Garage (REDLINE, BLUE THUNDER, NIGHT RIDER)
     - 105 MPH physics-driven semi-truck driving and articulated trailer hitch kinematics
     - 4-lane highway with Exit 42B interchange and road chevron arrows
     - Live AI Traffic with Sedans, SUVs, Sports Cars, Pickups, and aggressive "⚠ BRAKE!" warning triggers
     - 5-tier Road Rage accumulation
     - Dual roof-mounted turret Retaliation Mode with arcade projectiles and voxel debris explosions
     - 5-star Police Heat pursuit cruisers with flashing lightbars
     - Real-time GPS minimap, speedometer cluster, and scoring results screen
     - Web Audio sound synthesizer for diesel engine, brakes, horn, collisions, and combat SFX

3. **`export_presets.cfg`**
   - Pre-configured Godot 4 Web (HTML5) export preset targeting `public/index.html`.

4. **GitHub Actions CI/CD Workflow (`.github/workflows/deploy-vercel.yml`)**
   - Automatically compiles and exports the Godot 4 project to Web and deploys to Vercel on git push.

---

## Deployment Methods

### Method 1: Instant Deployment with Vercel CLI (Recommended)
Run the following command directly in your project root:
```bash
npx vercel
```
- When prompted:
  - *Set up and deploy?* -> `Y`
  - *Which scope?* -> Select your personal or team account
  - *Link to existing project?* -> `N`
  - *Project name?* -> `voxel-hauler`
  - *In which directory is your code located?* -> `./`
- To deploy straight to production:
```bash
npx vercel --prod
```
Your live URL will be generated immediately (e.g., `https://voxel-hauler.vercel.app`).

---

### Method 2: Git Integration via Vercel Dashboard
1. Push this repository to GitHub or GitLab:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Voxel Hauler"
   git remote add origin https://github.com/<your-username>/voxel-hauler.git
   git push -u origin main
   ```
2. Log into [vercel.com](https://vercel.com) and click **"Add New..." -> "Project"**.
3. Import your `voxel-hauler` repository.
4. Leave Framework Preset as **"Other"** and Root Directory as `./`.
5. Click **Deploy**. Vercel will serve the game on your production domain with SSL enabled.

---

### Method 3: Automated Godot Web Export via GitHub Actions
If you make changes in GDScript and want GitHub to compile the Godot WebAssembly build automatically:
1. In your GitHub repository, go to **Settings > Secrets and variables > Actions**.
2. Add the following secrets:
   - `VERCEL_TOKEN`: Your Vercel personal access token (create at vercel.com/account/tokens).
   - `VERCEL_ORG_ID`: Found in your project settings.
   - `VERCEL_PROJECT_ID`: Found in your project settings.
3. Every `git push` to `main` will automatically build the Godot engine Web export and push the build to Vercel.
