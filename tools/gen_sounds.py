"""Erzeugt die Effekt-Töne der App (reine Sinus-/Rausch-Synthese, keine fremden Rechte).

Aufruf:  python3 tools/gen_sounds.py Sources/LabubuApp/Resources
"""
import math, random, struct, wave, sys
SR = 44100
out = sys.argv[1]
random.seed(7)

def write(name, samples):
    peak = max(1e-9, max(abs(s) for s in samples))
    with wave.open(f"{out}/{name}.wav", "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(s / peak * 0.8 * 32767)) for s in samples))

def env(i, n, attack=0.005, decay=6.0):
    t = i / SR
    a = min(1.0, t / attack) if attack > 0 else 1.0
    return a * math.exp(-decay * t / (n / SR))

# "Plopp": kurzer, nach oben gleitender Ton – beim Antippen des Eis
n = int(SR * 0.12); ph = 0; s = []
for i in range(n):
    f = 420 + 700 * (i / n); ph += 2 * math.pi * f / SR
    s.append(math.sin(ph) * env(i, n, decay=5))
write("tap", s)

# "Knacks": Rauschimpuls + tiefer Klick – Riss im Ei
n = int(SR * 0.16); s = []; lp = 0
for i in range(n):
    lp += 0.35 * (random.uniform(-1, 1) - lp)
    click = math.sin(2 * math.pi * 180 * i / SR) * math.exp(-60 * i / SR)
    s.append((lp * 0.9 + click * 0.6) * env(i, n, attack=0.001, decay=9))
write("crack", s)

# Fanfare: C5 E5 G5 C6 + Glitzer – Schlüpfen
notes = [(523.25, .13), (659.25, .13), (783.99, .13), (1046.5, .55)]
s = []
for f, d in notes:
    n = int(SR * d)
    for i in range(n):
        t = i / SR
        tone = sum(math.sin(2 * math.pi * f * k * t) / k for k in (1, 2, 3)) * 0.5
        s.append(tone * env(i, n, attack=0.008, decay=3 if d > .3 else 4))
for i in range(int(SR * 0.4)):
    t = i / SR
    s.append(math.sin(2 * math.pi * (2093 + 400 * math.sin(40 * t)) * t) * 0.25 * math.exp(-6 * t))
write("hatch", s)

# Kichern: drei kurze, hüpfende Töne – Labubu antippen
s = []
for f in (880, 1046, 1318):
    n = int(SR * 0.09)
    for i in range(n):
        vib = 1 + 0.04 * math.sin(2 * math.pi * 30 * i / SR)
        s.append(math.sin(2 * math.pi * f * vib * i / SR) * env(i, n, decay=4))
    s.extend([0.0] * int(SR * 0.03))
write("giggle", s)

# Mampfen: zwei knusprige Bisse – Labubu isst
s = []
for _ in range(2):
    n = int(SR * 0.07); lp = 0
    for i in range(n):
        lp += 0.5 * (random.uniform(-1, 1) - lp)
        s.append(lp * env(i, n, attack=0.002, decay=5))
    s.extend([0.0] * int(SR * 0.09))
write("chomp", s)

# "Nö-nö": zwei absteigende Töne – Labubu ist satt
s = []
for f in (520, 390):
    n = int(SR * 0.14)
    for i in range(n):
        s.append(math.sin(2 * math.pi * f * i / SR) * env(i, n, attack=0.01, decay=3))
    s.extend([0.0] * int(SR * 0.05))
write("nope", s)

# Klick: Lichtschalter
n = int(SR * 0.04); s = []
for i in range(n):
    s.append((math.sin(2 * math.pi * 2200 * i / SR) * 0.6 + random.uniform(-1, 1) * 0.4) * math.exp(-120 * i / SR))
write("click", s)

# Schnarchen: leises, tiefes Brummen, das an- und abschwillt
n = int(SR * 1.2); s = []; lp = 0
for i in range(n):
    t = i / SR
    lp += 0.04 * (random.uniform(-1, 1) - lp)
    buzz = math.sin(2 * math.pi * 85 * t) * 0.5 + lp * 3
    s.append(buzz * math.sin(math.pi * t / 1.2) ** 2 * 0.5)
write("snore", s)
