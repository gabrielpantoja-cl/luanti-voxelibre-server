# Wetlands NPCs - Voice Mapping System

## Overview
Each NPC has a unique voice profile generated with Microsoft Edge Neural TTS (via `edge-tts` Python package). Star Wars NPCs speak English; classic NPCs speak Spanish.

## Generation Command
```bash
pip install edge-tts
# Then run the generation script (see tools/generate_voices.py)
# Convert to OGG: ffmpeg -y -i input.mp3 -ac 1 -c:a libvorbis -q:a 4 output.ogg
```

## Star Wars NPCs (English)

### Luke Skywalker
| Field | Value |
|-------|-------|
| Voice | `en-US-BrianNeural` |
| Personality | Approachable, Casual, Sincere |
| Character | Young Jedi hero, hopeful, kind |
| Rate | -5% |
| Pitch | +0Hz |
| Iconic phrase | "May the Force be with you... always." |

### Anakin Skywalker (Darth Vader)
| Field | Value |
|-------|-------|
| Voice | `en-US-GuyNeural` |
| Personality | Passionate, Intense |
| Character | Young Jedi/Sith, dramatic, powerful |
| Rate | -10% (slower for gravitas) |
| Pitch | -2Hz (slightly deeper) |
| Iconic phrase | "I am your father." |

### Baby Yoda (Grogu)
| Field | Value |
|-------|-------|
| Voice | `en-US-AnaNeural` |
| Personality | Cute, Cartoon |
| Character | 50-year-old baby alien, adorable, speaks inverted Yoda syntax |
| Rate | -10% |
| Pitch | +2Hz (higher, childlike) |
| Iconic phrase | "Do, or do not. There is no try!" |

### Mandalorian (Din Djarin)
| Field | Value |
|-------|-------|
| Voice | `en-US-ChristopherNeural` |
| Personality | Reliable, Authority |
| Character | Stoic bounty hunter, speaks through helmet, laconic |
| Rate | -10% |
| Pitch | -3Hz (deep, through-helmet feel) |
| Iconic phrase | "This is the way." |

## Classic NPCs (Spanish) - Pending voice upgrade

### Agricultor (Farmer)
| Field | Value |
|-------|-------|
| Voice | `en-AU-WilliamMultilingualNeural` (planned) |
| Personality | Friendly, Rural |
| Character | Earthy, warm, practical farmer |

### Bibliotecario (Librarian)
| Field | Value |
|-------|-------|
| Voice | `en-GB-ThomasNeural` (planned) |
| Personality | Friendly, Intellectual |
| Character | British-sounding, measured, bookish |

### Maestro (Teacher)
| Field | Value |
|-------|-------|
| Voice | `en-US-AndrewNeural` (planned) |
| Personality | Warm, Confident, Authentic |
| Character | Encouraging, pedagogical, motivating |

### Explorador (Explorer)
| Field | Value |
|-------|-------|
| Voice | `en-US-RogerNeural` (planned) |
| Personality | Lively |
| Character | Energetic, adventurous, excited |

## Sound Files Per NPC

Each NPC has these sound files:
- `wetlands_npc_greet_{name}1.ogg` - Greeting variant 1
- `wetlands_npc_greet_{name}2.ogg` - Greeting variant 2
- `wetlands_npc_talk_{name}1.ogg` - Talk variant 1
- `wetlands_npc_talk_{name}2.ogg` - Talk variant 2
- `wetlands_npc_talk_{name}3.ogg` - Talk variant 3
- `wetlands_npc_iconic_{name}.ogg` - Iconic phrase (Star Wars only)

## Rules
1. **No voice repeats** - each NPC must have a unique edge-tts voice ID
2. **Baby Yoda = child voice** - always use `en-US-AnaNeural` (Cute/Cartoon category)
3. **Star Wars = English** - dialogues and voice lines in English for bilingual learning
4. **Classic = Spanish** - dialogues and voice lines in Spanish for local audience
5. **Format** - OGG Vorbis, mono, quality 4 (`-ac 1 -c:a libvorbis -q:a 4`)
6. **Naming** - `wetlands_npc_{type}_{character}{variant}.ogg`

## Regenerating Voices
To regenerate all Star Wars voices, run from the mod directory:
```bash
python tools/generate_voices.py
```
