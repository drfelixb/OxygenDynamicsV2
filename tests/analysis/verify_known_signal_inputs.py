"""Independent pixel-level audit of MATLAB pilot inputs (NumPy and Pillow)."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


def verify(root):
    root = Path(root)
    manifest = json.loads((root / "manifest.json").read_text())
    source = Path(manifest["SourceTiff"])
    assert hashlib.sha256(source.read_bytes()).hexdigest() == manifest["SourceSHA256"]
    rows, cols = manifest["SourceRows"], manifest["SourceColumns"]
    first, last = manifest["SourceFrames"]
    height, width = rows[1] - rows[0] + 1, cols[1] - cols[0] + 1
    cx, cy = manifest["CircleCenterXY"]
    yy, xx = np.mgrid[1:height+1, 1:width+1]
    mask = (xx - cx)**2 + (yy - cy)**2 <= manifest["CircleRadiusPixels"]**2
    checked = 0
    with Image.open(source) as original:
        for case in manifest["Cases"]:
            with Image.open(root / case["Case"] / "pilot_original.tif") as injected:
                assert injected.n_frames == last - first + 1
                for frame in range(injected.n_frames):
                    original.seek(first - 1 + frame)
                    base = np.asarray(original)[rows[0]-1:rows[1], cols[0]-1:cols[1]].astype(float)
                    if any(a <= frame + 1 <= b for a, b in manifest["WindowsInclusive"]):
                        factor = 1 + case["GlobalFraction"] + case["LocalAdditiveFraction"] * mask
                        base *= factor
                    # MATLAB rounds positive half-integers away from zero.
                    expected = np.floor(base + 0.5).astype(np.uint16)
                    injected.seek(frame)
                    np.testing.assert_array_equal(np.asarray(injected), expected)
                    checked += expected.size
    result = {"AllPixelsMatchIndependentConstruction": True,
              "Cases": len(manifest["Cases"]), "PixelsVerified": checked}
    (root / "input-verification.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output_root")
    verify(parser.parse_args().output_root)
