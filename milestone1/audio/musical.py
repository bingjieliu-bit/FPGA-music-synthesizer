
import math

TABLE_SIZE = 1024
MAX_AMPLITUDE = 30000

# Harmonic weights for each synthetic timbre
piano_harmonics = [1.0, 0.65, 0.40, 0.25, 0.16, 0.10, 0.06]
guitar_harmonics = [1.0, 0.50, 0.25, 0.12, 0.08, 0.04]

def generate_table(harmonics, filename):
    samples = []

    for n in range(TABLE_SIZE):
        value = 0.0

        for k, amplitude in enumerate(harmonics, start=1):
            value += amplitude * math.sin(
                2 * math.pi * k * n / TABLE_SIZE
            )

        samples.append(value)

    # Normalize so the maximum magnitude reaches MAX_AMPLITUDE
    peak = max(abs(x) for x in samples)

    with open(filename, "w") as f:
        for sample in samples:
            scaled = round(sample / peak * MAX_AMPLITUDE)

            # Convert signed value to 16-bit two's complement
            hex_value = scaled & 0xFFFF

            f.write(f"{hex_value:04X}\n")

    print(f"{filename} generated!")

generate_table(piano_harmonics, "piano1024.hex")
generate_table(guitar_harmonics, "guitar1024.hex")

print("Both LUT files are ready.")
