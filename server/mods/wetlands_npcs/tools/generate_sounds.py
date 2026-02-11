#!/usr/bin/env python3
"""
Generate Animal Crossing-style NPC voice sounds for Wetlands NPCs mod.

Creates two types of sounds:
1. Talk sounds: short "mumble/babble" (3 variants per NPC = 24 files)
2. Greeting sounds: rising "Ho-la!" pattern (2 variants per NPC = 16 files)

8 NPC types with distinct pitch ranges:
Star Wars:
- Luke: mid heroic (200-320 Hz)
- Anakin: young intense (250-380 Hz)
- Yoda: high unusual (320-500 Hz)
- Mandalorian: deep helmet (120-200 Hz)
Classic:
- Farmer: mid-warm (180-280 Hz)
- Librarian: mid-soft (220-320 Hz)
- Teacher: mid-high (250-400 Hz)
- Explorer: low-deep (150-250 Hz)

Output: OGG Vorbis files in the sounds/ directory.
"""

import math
import os
import random
import struct
import subprocess
import tempfile
import wave

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sounds")

SAMPLE_RATE = 22050

NPC_VOICES = {
    # Star Wars
    "luke": (200, 320),
    "anakin": (250, 380),
    "yoda": (320, 500),
    "mandalorian": (120, 200),
    # Classic
    "farmer": (180, 280),
    "librarian": (220, 320),
    "teacher": (250, 400),
    "explorer": (150, 250),
}

TALK_VARIANTS = 3
GREET_VARIANTS = 2


def generate_syllable(freq, duration, sample_rate=SAMPLE_RATE):
    num_samples = int(sample_rate * duration)
    samples = []
    for i in range(num_samples):
        t = i / sample_rate
        envelope_pos = i / num_samples
        if envelope_pos < 0.1:
            envelope = envelope_pos / 0.1
        elif envelope_pos > 0.8:
            envelope = (1.0 - envelope_pos) / 0.2
        else:
            envelope = 1.0
        vibrato = math.sin(2 * math.pi * 5 * t) * 0.02
        sample = envelope * math.sin(2 * math.pi * (freq + freq * vibrato) * t)
        sample += 0.3 * envelope * math.sin(2 * math.pi * freq * 2 * t)
        sample += 0.1 * envelope * math.sin(2 * math.pi * freq * 3 * t)
        samples.append(sample * 0.5)
    return samples


def generate_mumble(min_freq, max_freq, seed):
    rng = random.Random(seed)
    samples = []
    num_syllables = rng.randint(3, 6)
    for _ in range(num_syllables):
        freq = rng.uniform(min_freq, max_freq)
        duration = rng.uniform(0.06, 0.15)
        samples.extend(generate_syllable(freq, duration))
        gap = int(SAMPLE_RATE * rng.uniform(0.02, 0.06))
        samples.extend([0.0] * gap)
    return samples


def generate_greeting(min_freq, max_freq, seed):
    rng = random.Random(seed)
    samples = []
    base_freq = rng.uniform(min_freq, (min_freq + max_freq) / 2)
    # "Ho" - lower
    samples.extend(generate_syllable(base_freq * rng.uniform(0.9, 1.0), rng.uniform(0.12, 0.18)))
    samples.extend([0.0] * int(SAMPLE_RATE * rng.uniform(0.03, 0.06)))
    # "la!" - higher
    samples.extend(generate_syllable(base_freq * rng.uniform(1.3, 1.6), rng.uniform(0.10, 0.16)))
    if rng.random() > 0.4:
        samples.extend([0.0] * int(SAMPLE_RATE * rng.uniform(0.02, 0.04)))
        samples.extend(generate_syllable(base_freq * rng.uniform(1.1, 1.4), rng.uniform(0.06, 0.10)))
    return samples


def samples_to_wav(samples, filepath):
    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        for sample in samples:
            clamped = max(-1.0, min(1.0, sample))
            wav_file.writeframes(struct.pack("<h", int(clamped * 32767)))


def wav_to_ogg(wav_path, ogg_path):
    subprocess.run(
        ["ffmpeg", "-y", "-i", wav_path, "-c:a", "libvorbis", "-q:a", "4", ogg_path],
        check=True, capture_output=True,
    )


def generate_and_save(sound_name, samples):
    ogg_path = os.path.join(OUTPUT_DIR, f"{sound_name}.ogg")
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        wav_path = tmp.name
    try:
        samples_to_wav(samples, wav_path)
        wav_to_ogg(wav_path, ogg_path)
        print(f"  {sound_name}.ogg ({len(samples)/SAMPLE_RATE:.2f}s)")
    finally:
        if os.path.exists(wav_path):
            os.unlink(wav_path)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"=== Generating talk sounds ({len(NPC_VOICES) * TALK_VARIANTS} files) ===")
    for npc_type, (min_freq, max_freq) in NPC_VOICES.items():
        for variant in range(1, TALK_VARIANTS + 1):
            seed = hash(f"{npc_type}_talk_{variant}") & 0xFFFFFFFF
            generate_and_save(f"wetlands_npc_talk_{npc_type}{variant}", generate_mumble(min_freq, max_freq, seed))

    print(f"\n=== Generating greeting sounds ({len(NPC_VOICES) * GREET_VARIANTS} files) ===")
    for npc_type, (min_freq, max_freq) in NPC_VOICES.items():
        for variant in range(1, GREET_VARIANTS + 1):
            seed = hash(f"{npc_type}_greet_{variant}") & 0xFFFFFFFF
            generate_and_save(f"wetlands_npc_greet_{npc_type}{variant}", generate_greeting(min_freq, max_freq, seed))

    total = len(NPC_VOICES) * (TALK_VARIANTS + GREET_VARIANTS)
    print(f"\nAll {total} sounds saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
