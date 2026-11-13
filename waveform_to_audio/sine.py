
import math

with open("sine1024.hex", "w") as file:
    for i in range(1024):

        value = round(32767 * math.sin(2 * math.pi * i / 1024))

        value &= 0xFFFF

        file.write(f"{value:04X}\n")
