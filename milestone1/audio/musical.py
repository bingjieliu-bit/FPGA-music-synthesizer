import math

TABLE_SIZE = 1024
MAX_AMPLITUDE = 30000

# Harmonic weights for each synthetic timbre
piano_harmonics = [
    1.00, 0.80, 0.55, 0.38, 0.28, 0.20,
    0.14, 0.10, 0.07, 0.05, 0.035, 0.025
]

guitar_harmonics = [
    1.00, 0.35, 0.65, 0.25, 0.40, 0.15, 0.22, 0.08
]


def generate_table(harmonics, filename):
    samples = []

    for n in range(TABLE_SIZE):
        value = 0.0

        for k, amplitude in enumerate(harmonics, start=1):
            value += amplitude * math.sin(
                2 * math.pi * k * n / TABLE_SIZE
            )

        samples.append(value)

    # Normalize
    peak = max(abs(x) for x in samples)

    with open(filename, "w") as f:
        for sample in samples:
            scaled = round(sample / peak * MAX_AMPLITUDE)

            # Signed 16-bit two's complement
            hex_value = scaled & 0xFFFF
            f.write(f"{hex_value:04X}\n")

    print(f"{filename} generated!")

def generate_envelope(filename):
    envelope = []

    attack = 0.08
    decay = 0.25
    sustain = 0.45

    for n in range(TABLE_SIZE):
        t = n / (TABLE_SIZE - 1)

        if t < attack:
            value = t / attack

        elif t < attack + decay:
            decay_progress = (t - attack) / decay
            value = 1.0 - decay_progress * (1.0 - sustain)

        else:
            value = sustain

        envelope.append(round(value * 255))

    with open(filename, "w") as f:
        for value in envelope:
            f.write(f"{value:02X}\n")

    print(f"{filename} generated!")


generate_table(piano_harmonics, "piano1024.hex")
generate_table(guitar_harmonics, "guitar1024.hex")

generate_envelope("envelope1024.hex")

print("All LUT files are ready.")
