#!/usr/bin/env python3
"""
Procedural Sound Effect Generator for VOXEL HAULER: ASPHALT RETALIATION
Synthesizes 16-bit 44.1kHz mono WAV files using standard library.
"""
import wave
import struct
import math
import random
import os

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
os.makedirs(OUT_DIR, exist_ok=True)

def write_wav(filename, samples):
    filepath = os.path.join(OUT_DIR, filename)
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        # Clamp and pack to 16-bit signed int
        packed = bytearray()
        for s in samples:
            clamped = max(-1.0, min(1.0, s))
            val = int(clamped * 32767)
            packed.extend(struct.pack('<h', val))
        wf.writeframes(packed)
    print(f"Generated {filename} ({len(samples)/SAMPLE_RATE:.2f}s)")

def gen_engine_loop(duration=1.0, base_freq=55.0):
    """Deep rumbling diesel engine idle sound"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Multiple sub-harmonics for throaty diesel combustion pulses
        pulse = (math.sin(2 * math.pi * base_freq * t) +
                 0.6 * math.sin(2 * math.pi * base_freq * 2 * t) +
                 0.3 * math.sin(2 * math.pi * base_freq * 3 * t) +
                 0.25 * math.sin(2 * math.pi * base_freq * 0.5 * t))
        # Add slight turbo whistle & mechanical rattle
        noise = (random.random() * 2.0 - 1.0) * 0.08
        whistle = math.sin(2 * math.pi * (base_freq * 18.0) * t) * 0.04
        sample = (pulse * 0.6 + noise + whistle) * 0.7
        samples.append(sample)
    return samples

def gen_air_brake(duration=0.6):
    """Pneumatic air brake discharge hiss"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 5.0) if t < 0.2 else (1.0 - (t - 0.2) / 0.4) * 0.6
        noise = (random.random() * 2.0 - 1.0)
        # High-pass filter feel
        sample = noise * max(0.0, env) * 0.6
        samples.append(sample)
    return samples

def gen_horn(duration=0.8):
    """Deep dual-chime semi truck air horn"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    f1, f2 = 220.0, 277.18 # Dual tone
    for i in range(n):
        t = i / SAMPLE_RATE
        env = 1.0
        if t < 0.05: env = t / 0.05
        elif t > duration - 0.1: env = (duration - t) / 0.1
        tone = (math.sin(2 * math.pi * f1 * t) + 
                0.8 * math.sin(2 * math.pi * f2 * t) +
                0.3 * math.sin(2 * math.pi * f1 * 2 * t))
        samples.append(tone * env * 0.5)
    return samples

def gen_tire_squeal(duration=0.5):
    """Arcade tire drift / squeal"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration))
        freq = 800.0 + math.sin(t * 30.0) * 150.0
        tone = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * 0.3
        samples.append((tone * 0.5 + noise) * env * 0.4)
    return samples

def gen_collision(duration=0.5):
    """Heavy metal crunch & glass impact"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 10.0)
        low_boom = math.sin(2 * math.pi * (70.0 * (1.0 - t*0.5)) * t) * 0.8
        noise = (random.random() * 2.0 - 1.0) * 0.9
        sample = (low_boom + noise) * env * 0.8
        samples.append(sample)
    return samples

def gen_rage_alert(duration=0.4):
    """Tension alert chime indicating rising rage"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 6.0)
        freq = 440.0 + t * 400.0
        sample = math.sin(2 * math.pi * freq * t) * env * 0.5
        samples.append(sample)
    return samples

def gen_retaliation_ready(duration=0.8):
    """Dramatic synth power-up riser for Retaliation Ready"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = min(1.0, t / 0.1) * (1.0 - (t / duration) * 0.3)
        freq = 200.0 * (2.0 ** (t * 2.5)) # Dramatic upward sweep
        square = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        sin = math.sin(2 * math.pi * freq * t)
        sample = (square * 0.4 + sin * 0.6) * env * 0.6
        samples.append(sample)
    return samples

def gen_turret_deploy(duration=0.6):
    """Hydraulic mechanical servo opening sound"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration))
        freq = 300.0 + math.sin(t * 50.0) * 50.0
        motor = math.sin(2 * math.pi * freq * t)
        click = 0.5 if (i % 1200 < 50) else 0.0
        samples.append((motor * 0.4 + click) * env * 0.5)
    return samples

def gen_machine_gun_shot(duration=0.18):
    """Punchy twin-barrel arcade bullet crack"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        transient = (random.random() * 2.0 - 1.0)
        punch = math.sin(2 * math.pi * (180.0 * (1.0 - t * 3.0)) * t)
        sample = (punch * 0.6 + transient * 0.7) * env * 0.85
        samples.append(sample)
    return samples

def gen_explosion(duration=1.2):
    """Deep voxel shattering explosion"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        boom = math.sin(2 * math.pi * (60.0 * (1.0 - t * 0.6)) * t)
        debris = (random.random() * 2.0 - 1.0) * (0.8 if t < 0.3 else 0.4)
        sample = (boom * 0.7 + debris * 0.6) * env * 0.9
        samples.append(sample)
    return samples

def gen_police_siren(duration=1.2):
    """Arcade two-tone high/low police pursuit siren loop"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Wailing sine LFO between 650Hz and 950Hz
        freq = 800.0 + math.sin(2 * math.pi * (1.5) * t) * 180.0
        tone = math.sin(2 * math.pi * freq * t)
        harm = math.sin(2 * math.pi * freq * 2 * t) * 0.3
        samples.append((tone + harm) * 0.4)
    return samples

def gen_victory(duration=2.0):
    """Triumphant brass delivery completion fanfare"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    notes = [261.63, 329.63, 392.00, 523.25] # C, E, G, C (higher)
    for i in range(n):
        t = i / SAMPLE_RATE
        idx = min(3, int(t / 0.4))
        f = notes[idx]
        note_t = t - idx * 0.4
        env = math.exp(-note_t * 1.5)
        sample = (math.sin(2 * math.pi * f * t) + 0.4 * math.sin(2 * math.pi * f * 2 * t)) * env * 0.5
        samples.append(sample)
    return samples

def gen_defeat(duration=1.5):
    """Low somber delivery failure / captured cue"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    notes = [220.0, 207.65, 196.0, 174.61] # Descending tones
    for i in range(n):
        t = i / SAMPLE_RATE
        idx = min(3, int(t / 0.35))
        f = notes[idx]
        note_t = t - idx * 0.35
        env = math.exp(-note_t * 2.0)
        sample = (math.sin(2 * math.pi * f * t) + 0.3 * math.sin(2 * math.pi * f * 0.5 * t)) * env * 0.5
        samples.append(sample)
    return samples

def gen_ui_click(duration=0.08):
    """Crisp high-tech UI button click"""
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 50.0)
        sample = math.sin(2 * math.pi * 1200.0 * t) * env * 0.4
        samples.append(sample)
    return samples

if __name__ == "__main__":
    write_wav("engine_loop.wav", gen_engine_loop(1.2, 55.0))
    write_wav("air_brake.wav", gen_air_brake(0.6))
    write_wav("horn.wav", gen_horn(0.8))
    write_wav("tire_squeal.wav", gen_tire_squeal(0.5))
    write_wav("collision.wav", gen_collision(0.5))
    write_wav("rage_alert.wav", gen_rage_alert(0.35))
    write_wav("retaliation_ready.wav", gen_retaliation_ready(0.85))
    write_wav("turret_deploy.wav", gen_turret_deploy(0.6))
    write_wav("machine_gun.wav", gen_machine_gun_shot(0.18))
    write_wav("explosion.wav", gen_explosion(1.2))
    write_wav("police_siren.wav", gen_police_siren(1.2))
    write_wav("victory.wav", gen_victory(2.0))
    write_wav("defeat.wav", gen_defeat(1.5))
    write_wav("ui_click.wav", gen_ui_click(0.08))
    print("All audio files successfully generated!")
