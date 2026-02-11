#!/usr/bin/env python3
"""
Generate Star Wars NPC voice sounds using Microsoft Edge Neural TTS.

Requires: pip install edge-tts
Requires: ffmpeg in PATH

Generates for each Star Wars NPC:
- 2 greeting sounds (short phrases)
- 3 talk sounds (character-specific lines)
- 1 iconic sound (signature catchphrase)

Voice mapping (unique per character, NO repeats):
- Luke Skywalker:  en-US-BrianNeural       (Approachable, Sincere)
- Anakin/Vader:    en-US-GuyNeural          (Passionate, Intense)
- Baby Yoda:       en-US-AnaNeural          (Cute, Cartoon - child voice!)
- Mandalorian:     en-US-ChristopherNeural  (Reliable, Authority)

Classic NPCs (planned, not yet implemented here):
- Farmer:          en-AU-WilliamMultilingualNeural  (Friendly, Rural)
- Librarian:       en-GB-ThomasNeural               (Friendly, Intellectual)
- Teacher:         en-US-AndrewNeural                (Warm, Confident)
- Explorer:        en-US-RogerNeural                 (Lively, Energetic)

Output: OGG Vorbis mono files in the sounds/ directory.
"""

import asyncio
import os
import subprocess
import sys

try:
    import edge_tts
except ImportError:
    print("ERROR: edge-tts not installed. Run: pip install edge-tts")
    sys.exit(1)

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sounds")

# ============================================================================
# VOICE PROFILES - Each character has a unique voice. DO NOT DUPLICATE.
# ============================================================================
STAR_WARS_VOICES = {
    "luke": {
        "voice": "en-US-BrianNeural",
        "rate": "-5%",
        "pitch": "+0Hz",
        "greet": [
            "Hey there, friend!",
            "The Force is strong today!",
        ],
        "talk": [
            "I destroyed the Death Star with one shot!",
            "My lightsaber is green, powered by a Kyber crystal.",
            "Han Solo is my best friend in the galaxy.",
        ],
        "iconic": "May the Force be with you... always.",
    },
    "anakin": {
        "voice": "en-US-GuyNeural",
        "rate": "-10%",
        "pitch": "-2Hz",
        "greet": [
            "I am the chosen one!",
            "The Force is strong with you.",
        ],
        "talk": [
            "I was the best pilot in the galaxy at age nine.",
            "My lightsaber is blue, the color of Jedi Guardians.",
            "I built C-3PO from recycled parts. He speaks six million languages!",
        ],
        "iconic": "I am your father.",
    },
    "yoda": {
        "voice": "en-US-AnaNeural",
        "rate": "-10%",
        "pitch": "+2Hz",
        "greet": [
            "Goo goo! Welcome you are!",
            "Strong the Force is in you!",
        ],
        "talk": [
            "Small I am, but powerful. Judge me by my size, do not!",
            "Frogs I really like. Delicious they are!",
            "Fifty years old I am, but a baby still.",
        ],
        "iconic": "Do, or do not. There is no try!",
    },
    "mandalorian": {
        "voice": "en-US-ChristopherNeural",
        "rate": "-10%",
        "pitch": "-3Hz",
        "greet": [
            "This is the Way.",
            "I have spoken.",
        ],
        "talk": [
            "My armor is pure beskar, forged by the Armorer.",
            "I never remove my helmet. It is the creed.",
            "My mission is to protect the Child.",
        ],
        "iconic": "This is the way.",
    },
}


def mp3_to_ogg(mp3_path, ogg_path):
    """Convert MP3 to OGG Vorbis mono."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", mp3_path, "-ac", "1", "-c:a", "libvorbis", "-q:a", "4", ogg_path],
        check=True, capture_output=True,
    )


async def generate_sound(name, text, voice, rate, pitch):
    """Generate a single sound file."""
    mp3_path = os.path.join(OUTPUT_DIR, f"{name}.mp3")
    ogg_path = os.path.join(OUTPUT_DIR, f"{name}.ogg")

    comm = edge_tts.Communicate(text=text, voice=voice, rate=rate, pitch=pitch)
    await comm.save(mp3_path)
    mp3_to_ogg(mp3_path, ogg_path)
    os.unlink(mp3_path)

    size_kb = os.path.getsize(ogg_path) / 1024
    print(f"  {name}.ogg ({size_kb:.1f} KB) - {voice}")


async def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    total = 0
    for npc, config in STAR_WARS_VOICES.items():
        print(f"\n=== {npc.upper()} ({config['voice']}) ===")
        voice = config["voice"]
        rate = config["rate"]
        pitch = config["pitch"]

        # Greetings
        for i, text in enumerate(config["greet"], 1):
            await generate_sound(f"wetlands_npc_greet_{npc}{i}", text, voice, rate, pitch)
            total += 1

        # Talk
        for i, text in enumerate(config["talk"], 1):
            await generate_sound(f"wetlands_npc_talk_{npc}{i}", text, voice, rate, pitch)
            total += 1

        # Iconic
        await generate_sound(f"wetlands_npc_iconic_{npc}", config["iconic"], voice, rate, pitch)
        total += 1

    print(f"\nGenerated {total} sound files in: {OUTPUT_DIR}")


if __name__ == "__main__":
    asyncio.run(main())
