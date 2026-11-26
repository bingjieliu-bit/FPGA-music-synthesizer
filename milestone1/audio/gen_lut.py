import math

TABLE_SIZE = 1024
MAX_AMPLITUDE = 30000
NUM_HARMONICS = 16


# ---------------------------------------------------------------------------
# Harmonic amplitudes derived from ideal-string physics
#
# A string excited at a fraction `beta` of its length (measured from the
# bridge) has mode n weighted by sin(n*pi*beta). Every harmonic that has a
# node at the excitation point (n = 1/beta, 2/beta, ...) is missing.
#
#   Guitar (plucked):  sound ~ string velocity at bridge -> sin(n*pi*beta) / n
#   Piano  (struck):   same sin term / n, then a low-pass from the felt hammer's
#                      finite contact time -> 1 / (1 + (n/nc)^2)
#
# Signs are kept (some harmonics come out negative): they don't change the
# timbre much, but they give the correct waveform shape.
# ---------------------------------------------------------------------------

def guitar_harmonics(beta=0.20, n_max=NUM_HARMONICS):
    """Plucked string. beta ~0.2 = plucked about 1/5 of the way from the bridge
    (typical over the soundhole), so harmonics 5, 10, 15 are missing."""
    a = [math.sin(n * math.pi * beta) / n for n in range(1, n_max + 1)]
    return [x / abs(a[0]) for x in a]


def piano_harmonics(beta=1/8, nc=6.0, n_max=NUM_HARMONICS):
    """Struck string. beta ~1/8 = hammer position for mid-range notes (~C4),
    so harmonic 8 is missing. nc controls brightness: larger = louder/brighter
    blow, smaller = softer blow."""
    a = [math.sin(n * math.pi * beta) / n / (1 + (n / nc) ** 2)
         for n in range(1, n_max + 1)]
    return [x / abs(a[0]) for x in a]


def generate_table(harmonics, filename):
    samples = []
    for n in range(TABLE_SIZE):
        value = 0.0
        for k, amplitude in enumerate(harmonics, start=1):
            value += amplitude * math.sin(2 * math.pi * k * n / TABLE_SIZE)
        samples.append(value)

    peak = max(abs(x) for x in samples)

    with open(filename, "w") as f:
        for sample in samples:
            scaled = round(sample / peak * MAX_AMPLITUDE)
            f.write(f"{scaled & 0xFFFF:04X}\n")   # signed 16-bit two's complement

    print(f"{filename} generated!")


# ---------------------------------------------------------------------------
# Envelopes: piano and guitar have NO sustain level. The note is a fast
# attack followed by an exponential decay that continues until release.
# ---------------------------------------------------------------------------

def generate_envelope(filename, attack=0.01, decay_rate=4.0):
    """Address = envelope phase (0..1023), NOT time and NOT the waveform phase.
    Drive it with its own slow phase accumulator, reset to 0 on note-on, and
    SATURATE at 1023 (do not wrap) or the note re-triggers.
    attack: fraction of envelope phase for the rise (very short, percussive).
    decay_rate: higher = faster decay (piano ~3-4, guitar ~5-6)."""
    with open(filename, "w") as f:
        for n in range(TABLE_SIZE):
            phase = n / (TABLE_SIZE - 1)
            if phase < attack:
                value = phase / attack
            else:
                value = math.exp(-decay_rate * (phase - attack))
            f.write(f"{round(value * 255):02X}\n")

    print(f"{filename} generated!")


piano = piano_harmonics()
guitar = guitar_harmonics()
print("piano :", [round(x, 3) for x in piano])
print("guitar:", [round(x, 3) for x in guitar])

generate_table(piano, "piano1024.hex")
generate_table(guitar, "guitar1024.hex")

generate_envelope("envelope_piano1024.hex", attack=0.005, decay_rate=3.5)
generate_envelope("envelope_guitar1024.hex", attack=0.005, decay_rate=5.0)

print("All LUT files are ready.")
