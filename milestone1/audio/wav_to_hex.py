
import numpy as np
from scipy.io import wavfile
from scipy.signal import resample_poly
from math import gcd

sample_rate, audio = wavfile.read("hihat_closed.wav")

# Normalize BEFORE converting stereo to mono
if np.issubdtype(audio.dtype, np.integer):
    info = np.iinfo(audio.dtype)
    audio = audio.astype(np.float64) / max(abs(info.min), info.max)
else:
    audio = audio.astype(np.float64)

# Convert to mono
if audio.ndim == 2:
    audio = audio.mean(axis=1)

# Resample to 48 kHz
target_rate = 48000
g = gcd(sample_rate, target_rate)

audio = resample_poly(
    audio,
    target_rate // g,
    sample_rate // g
)

# Trim to 0.5 seconds
audio = audio[:24000]

# Fade out the final 30 ms
fade_samples = min(1440, len(audio))

if fade_samples > 0:
    audio[-fade_samples:] *= np.linspace(1, 0, fade_samples)

# Normalize to 90% of maximum amplitude
peak = np.max(np.abs(audio))

if peak > 0:
    audio = audio / peak * 0.9

# Convert to signed 16-bit
audio = np.clip(audio, -1.0, 1.0)
audio = np.round(audio * 32767).astype(np.int16)

# Write HEX
with open("hihat.hex", "w") as f:
    for sample in audio:
        f.write("{:04X}\n".format(int(sample) & 0xFFFF))

print("Number of samples:", len(audio))
print("Duration:", len(audio) / target_rate)
print("Peak amplitude:", np.max(np.abs(audio.astype(np.int32))))
