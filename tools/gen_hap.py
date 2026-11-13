"""Fünf schnelle, selbst synthetisierte Monster-„Hap“-Silben, ohne Sprachdienst.

python3 tools/gen_hap.py Sources/LabubuApp/Resources/hap.wav
"""
import math
import random
import struct
import sys
import wave

SR = 44100
rng = random.Random(23)
samples = []
for syllable in range(5):
    # Ein gehauchtes H, ein kurzes A mit Formanten und ein kleiner P-Verschluss.
    for i in range(round(0.025 * SR)):
        t = i / SR
        samples.append(rng.uniform(-0.12, 0.12) * math.sin(math.pi * t / 0.025))
    count = round(0.15 * SR)
    for i in range(count):
        t = i / SR
        f = 175 + syllable * 8
        phase = 2 * math.pi * (f * t - 40 * t * t)
        vowel = 0.0
        for harmonic in range(1, 25):
            frequency = f * harmonic
            weight = sum(gain * math.exp(-0.5 * ((frequency - center) / width) ** 2)
                         for center, width, gain in [(730, 130, 1), (1090, 180, 0.7), (2440, 250, 0.2)])
            vowel += math.sin(phase * harmonic) * (weight + 0.12 / harmonic)
        envelope = min(1, t / 0.012) * (1 - i / count) ** 0.5
        samples.append(vowel * envelope)
    for i in range(round(0.02 * SR)):
        samples.append(rng.uniform(-0.25, 0.25) * math.exp(-i / (SR * 0.003)))
    samples.extend([0.0] * round(0.045 * SR))

peak = max(abs(sample) for sample in samples)
with wave.open(sys.argv[1], "wb") as output:
    output.setnchannels(1)
    output.setsampwidth(2)
    output.setframerate(SR)
    output.writeframes(b"".join(struct.pack("<h", round(sample / peak * 0.8 * 32767)) for sample in samples))
