"""Eigene ruhige Spieluhr-Schleife, ohne externe Samples.

Aufruf: python3 tools/gen_music.py Sources/LabubuApp/Resources/musicbox.wav
Die Ausklänge werden über die Loop-Grenze gewickelt, damit kein Schnitt klickt.
"""
import array
import math
import sys
import wave

SR = 44100
BEAT = 0.75
LENGTH = int(32 * BEAT * SR)
samples = [0.0] * LENGTH


def note(midi, beat, volume, duration=2.4):
    frequency = 440 * 2 ** ((midi - 69) / 12)
    start = round(beat * BEAT * SR)
    count = int(duration * SR)
    for i in range(count):
        t = i / SR
        envelope = min(1, t / 0.012) * math.exp(-3 * t) * (1 - i / count) ** 2
        tone = math.sin(2 * math.pi * frequency * t)
        tone += 0.18 * math.sin(2 * math.pi * frequency * 2 * t) * math.exp(-4 * t)
        samples[(start + i) % LENGTH] += volume * envelope * tone


# Helle, sparsame Melodie in C-Dur, mit Atempausen zwischen den Phrasen.
melody = [
    (0, 72), (1, 76), (2, 79), (4, 81), (5, 79), (6, 76),
    (8, 74), (9, 77), (10, 79), (12, 76), (14, 72),
    (16, 72), (17, 76), (18, 79), (20, 84), (22, 81),
    (24, 77), (25, 76), (26, 74), (28, 72),
]
for beat, midi in melody:
    note(midi, beat, 0.6)
for bar, chord in enumerate([(48, 55, 60), (53, 60, 65), (55, 62, 67), (48, 55, 60),
                             (48, 55, 60), (57, 60, 64), (53, 60, 65), (48, 55, 60)]):
    for step, midi in enumerate(chord):
        note(midi, bar * 4 + step, 0.22, duration=3.0)

peak = max(abs(value) for value in samples)
pcm = array.array("h", (round(value / peak * 0.75 * 32767) for value in samples))
if sys.byteorder != "little":
    pcm.byteswap()
with wave.open(sys.argv[1], "wb") as output:
    output.setnchannels(1)
    output.setsampwidth(2)
    output.setframerate(SR)
    output.writeframes(pcm.tobytes())
