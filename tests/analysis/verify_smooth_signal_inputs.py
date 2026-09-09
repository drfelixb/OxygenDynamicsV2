"""Verify all constructed pixels against source plus the recorded injection ledger."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


def verify(root):
    root = Path(root)
    manifests = sorted(root.glob('*/*/challenge-manifest.json'))
    assert len(manifests) == 12, 'Expected three recordings and four cases each.'
    checked = 0
    for path in manifests:
        m = json.loads(path.read_text())
        source = Path(m['SourceTiff'])
        assert hashlib.sha256(source.read_bytes()).hexdigest() == m['SourceSHA256']
        yy, xx = np.mgrid[1:m['Height']+1, 1:m['Width']+1]
        masks = [(xx-x)**2 + (yy-y)**2 <= m['RadiusPixels']**2 for x, y in m['CentersXY']]
        fraction = np.asarray(m['FractionBySignAndFrame'])
        assert fraction.shape == (2, m['Frames'])
        with Image.open(source) as original, Image.open(path.parent / 'challenge_original.tif') as generated:
            assert original.n_frames == generated.n_frames == m['Frames']
            for t in range(m['Frames']):
                original.seek(t)
                raw = np.asarray(original).astype(float)
                assert raw.shape == (m['Height'], m['Width'])
                factor = np.ones_like(raw)
                for k in range(2):
                    factor[masks[k]] = 1 + fraction[k, t]
                unrounded = raw * factor
                generated.seek(t)
                actual = np.asarray(generated)
                expected = np.floor(unrounded + .5).astype(np.uint16)
                unequal = actual != expected
                # JSON serialization can perturb an exact half-count tie.
                if np.any(unequal):
                    assert np.all(np.abs(unrounded[unequal] - actual[unequal]) <= .500000001)
                    assert np.all(np.abs(unrounded[unequal] % 1 - .5) < 1e-9)
                checked += actual.size
    report = {'InputMoviesVerified': len(manifests), 'PixelsVerified': checked,
              'SourceAndRecordedFractionsVerified': True,
              'RoundingTieToleranceCounts': 1e-9,
              'NoiseRNGRegeneratedIndependently': False}
    (root / 'input-verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root')
    verify(parser.parse_args().root)
