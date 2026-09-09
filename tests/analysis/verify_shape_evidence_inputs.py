"""Verify complete expanding/contracting movies from independently rebuilt recipes."""
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np
from PIL import Image


def verify(root):
    root = Path(root)
    manifests = sorted(root.glob('*/*/challenge-manifest.json'))
    assert len(manifests) == 8
    count = 0
    for path in manifests:
        m = json.loads(path.read_text())
        source = Path(m['SourceTiff'])
        assert hashlib.sha256(source.read_bytes()).hexdigest() == m['SourceSHA256']
        n = m['Frames']
        assert m['SampleHz'] == 1 and m['Windows'] == [101, 160]
        expected_radii = np.full(n, 60.0)
        bounds = (60, 120) if m['Case'] == 'growing_clean' else (120, 60)
        assert m['Case'] in ('growing_clean', 'shrinking_clean')
        expected_radii[100:160] = np.linspace(*bounds, 60)
        assert np.allclose(m['RadiusUmByFrame'], expected_radii, atol=1e-12, rtol=0)
        expected_fraction = np.zeros((2, n))
        expected_fraction[:, 100:160] = np.array([-1, 1])[:, None] * (.2 * np.sin(np.pi * np.arange(1, 61)/61)**2)
        assert np.allclose(m['FractionBySignAndFrame'], expected_fraction, atol=1e-14, rtol=0)
        centers = np.array([[np.floor(.33*m['Width']+.5), np.floor(.5*m['Height']+.5)],
                            [np.floor(.67*m['Width']+.5), np.floor(.5*m['Height']+.5)]])
        assert np.array_equal(m['CentersXY'], centers)
        yy, xx = np.mgrid[1:m['Height']+1, 1:m['Width']+1]
        with Image.open(source) as original, Image.open(path.parent/'challenge_original.tif') as actual:
            assert original.n_frames == actual.n_frames == n
            for t in range(n):
                original.seek(t)
                raw = np.array(original, dtype=float)
                factor = np.ones_like(raw)
                occupied = np.zeros_like(raw, dtype=bool)
                if 100 <= t < 160:
                    for k in range(2):
                        mask = (xx-centers[k, 0])**2+(yy-centers[k, 1])**2 <= (expected_radii[t]/m['SourceProfile']['PixelSize'])**2
                        assert not np.any(occupied & mask)
                        occupied |= mask
                        factor[mask] += expected_fraction[k, t]
                unrounded = raw * factor
                assert unrounded.min() >= 0 and unrounded.max() <= 65535
                actual.seek(t)
                got = np.asarray(actual)
                expected = np.floor(unrounded+.5).astype(np.uint16)
                different = got != expected
                if np.any(different):
                    assert np.all(np.abs(unrounded[different]-got[different]) <= .500000001)
                    assert np.all(np.abs(unrounded[different] % 1-.5) < 1e-9)
                count += got.size
    report = dict(NewMoviesVerified=8, PixelsVerified=count, AnalyticRadiusAndPulseVerified=True,
                  AllSourceHashesVerified=True, NoClipping=True, RoundingTieToleranceCounts=1e-9)
    (root/'input-verification.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root')
    verify(parser.parse_args().root)
