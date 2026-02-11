#!/usr/bin/env python3
"""
Generate Animal Crossing-style NPC voice sounds for Wetlands NPCs mod.

Creates two types of sounds:
1. Talk sounds: short "mumble/babble" (3 variants per NPC = 12 files)
2. Greeting sounds: rising "Ho-la!" pattern (2 variants per NPC = 8 files)

Each NPC type has a distinct pitch range:
- Farmer: mid-warm (180-280 Hz)
- Librarian: mid-soft (220-320 Hz)
- Teacher: low-wise (140-220 Hz)
- Explorer: high-energetic (280-420 Hz)

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

# Pitch ranges per NPC type (min_hz, max_hz)
NPC_VOICES = {
    "farmer": (180, 280),
    "librarian": (220, 320),
    "teacher": (140, 220),
    "explorer": (280, 420),
}

TALK_VARIANTS = 3
GREET_VARIANTS = 2


def generate_syllable(freq: float, duration: float, sample_rate: int = SAMPLE_RATE) -> list[float]:
    """Generate a single syllable (sine wave with envelope)."""
    num_samples = int(sample_rate * duration)
    samples = []

    for i in range(num_samples):
        t = i / sample_rate
        # Envelope: quick attack, sustain, quick release
        envelope_pos = i / num_samples
        if envelope_pos < 0.1:
            envelope = envelope_pos / 0.1  # Attack
        elif envelope_pos > 0.8:
            envelope = (1.0 - envelope_pos) / 0.2  # Release
        else:
            envelope = 1.0  # Sustain

        # Add slight vibrato for natural feel
        vibrato = math.sin(2 * math.pi * 5 * t) * 0.02
        sample = envelope * math.sin(2 * math.pi * (freq + freq * vibrato) * t)

        # Add a touch of harmonics for richness
        sample += 0.3 * envelope * math.sin(2 * math.pi * freq * 2 * t)
        sample += 0.1 * envelope * math.sin(2 * math.pi * freq * 3 * t)

        samples.append(sample * 0.5)  # Scale down to avoid clipping

    return samples


def generate_mumble(min_freq: float, max_freq: float, seed: int) -> list[float]:
    """Generate a complete mumble sound (multiple syllables)."""
    rng = random.Random(seed)
    samples = []

    # 3-6 syllables per mumble
    num_syllables = rng.randint(3, 6)

    for _ in range(num_syllables):
        freq = rng.uniform(min_freq, max_freq)
        duration = rng.uniform(0.06, 0.15)  # Short syllables

        syllable = generate_syllable(freq, duration)
        samples.extend(syllable)

        # Small gap between syllables
        gap_samples = int(SAMPLE_RATE * rng.uniform(0.02, 0.06))
        samples.extend([0.0] * gap_samples)

    return samples


def generate_greeting(min_freq: float, max_freq: float, seed: int) -> list[float]:
    """Generate a greeting sound: rising "Ho-la!" two-syllable pattern.

    The greeting has a distinctive rising pitch that sounds friendly,
    like saying "Hola!" in an Animal Crossing style.
    """
    rng = random.Random(seed)
    samples = []

    # Base frequency in the NPC's range
    base_freq = rng.uniform(min_freq, (min_freq + max_freq) / 2)

    # Syllable 1: "Ho" - lower, slightly longer
    freq1 = base_freq * rng.uniform(0.9, 1.0)
    duration1 = rng.uniform(0.12, 0.18)
    syllable1 = generate_syllable(freq1, duration1)
    samples.extend(syllable1)

    # Short pause between syllables
    gap = int(SAMPLE_RATE * rng.uniform(0.03, 0.06))
    samples.extend([0.0] * gap)

    # Syllable 2: "la!" - higher pitch (rising), shorter, more energetic
    freq2 = base_freq * rng.uniform(1.3, 1.6)
    duration2 = rng.uniform(0.10, 0.16)
    syllable2 = generate_syllable(freq2, duration2)
    samples.extend(syllable2)

    # Optional third syllable for some variants (like an exclamation)
    if rng.random() > 0.4:
        gap2 = int(SAMPLE_RATE * rng.uniform(0.02, 0.04))
        samples.extend([0.0] * gap2)

        freq3 = base_freq * rng.uniform(1.1, 1.4)
        duration3 = rng.uniform(0.06, 0.10)
        syllable3 = generate_syllable(freq3, duration3)
        samples.extend(syllable3)

    return samples


def samples_to_wav(samples: list[float], filepath: str):
    """Write samples to a WAV file."""
    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)

        for sample in samples:
            # Clamp to [-1, 1] and convert to 16-bit int
            clamped = max(-1.0, min(1.0, sample))
            packed = struct.pack("<h", int(clamped * 32767))
            wav_file.writeframes(packed)


def wav_to_ogg(wav_path: str, ogg_path: str):
    """Convert WAV to OGG Vorbis using ffmpeg."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", wav_path, "-c:a", "libvorbis", "-q:a", "4", ogg_path],
        check=True,
        capture_output=True,
    )


def generate_and_save(sound_name: str, samples: list[float]):
    """Save samples as OGG via temporary WAV."""
    ogg_path = os.path.join(OUTPUT_DIR, f"{sound_name}.ogg")

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        wav_path = tmp.name

    try:
        samples_to_wav(samples, wav_path)
        wav_to_ogg(wav_path, ogg_path)
        duration = len(samples) / SAMPLE_RATE
        print(f"  Generated: {sound_name}.ogg ({duration:.2f}s)")
    finally:
        if os.path.exists(wav_path):
            os.unlink(wav_path)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("=== Generating talk sounds (12 files) ===")
    for npc_type, (min_freq, max_freq) in NPC_VOICES.items():
        for variant in range(1, TALK_VARIANTS + 1):
            sound_name = f"wetlands_npc_talk_{npc_type}{variant}"
            seed = hash(f"{npc_type}_talk_{variant}") & 0xFFFFFFFF
            samples = generate_mumble(min_freq, max_freq, seed)
            generate_and_save(sound_name, samples)

    print("\n=== Generating greeting sounds (8 files) ===")
    for npc_type, (min_freq, max_freq) in NPC_VOICES.items():
        for variant in range(1, GREET_VARIANTS + 1):
            sound_name = f"wetlands_npc_greet_{npc_type}{variant}"
            seed = hash(f"{npc_type}_greet_{variant}") & 0xFFFFFFFF
            samples = generate_greeting(min_freq, max_freq, seed)
            generate_and_save(sound_name, samples)

    print(f"\nAll 20 sounds saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
