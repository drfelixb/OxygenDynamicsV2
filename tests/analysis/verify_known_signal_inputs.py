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
    yy, xx = np.mgrid[1:257, 1:257]
    mask = (xx - 128)**2 + (yy - 128)**2 <= 18**2
    checked = 0
    with Image.open(source) as original:
        for case in manifest["Cases"]:
            with Image.open(root / case["Case"] / "pilot_original.tif") as injected:
                assert injected.n_frames == 180
                for frame in range(180):
                    original.seek(frame)
                    base = np.asarray(original)[128:384, 128:384].astype(float)
                    if 60 <= frame < 80 or 95 <= frame < 115:
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
