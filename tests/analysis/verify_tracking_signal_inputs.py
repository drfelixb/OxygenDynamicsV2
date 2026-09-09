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
    assert len(manifests) == 20, 'Expected four recordings and five cases each.'
    checked = 0
    for path in manifests:
        m = json.loads(path.read_text())
        source = Path(m['SourceTiff'])
        assert hashlib.sha256(source.read_bytes()).hexdigest() == m['SourceSHA256']
        yy, xx = np.mgrid[1:m['Height']+1, 1:m['Width']+1]
        center_x = np.asarray(m['CenterXBySignAndFrame'])
        center_y = np.asarray(m['CenterYBySignAndFrame'])
        assert center_x.shape == center_y.shape == (2, m['Frames'])
        fraction = np.asarray(m['FractionBySignAndFrame'])
        assert fraction.shape == (2, m['Frames'])
        expected_x = np.repeat(np.asarray(m['CentersXY'])[:, :1], m['Frames'], axis=1)
        expected_y = np.repeat(np.asarray(m['CentersXY'])[:, 1:2], m['Frames'], axis=1)
        if m['Case'] == 'moving_clean':
            expected_x[:, 100:160] = np.floor(np.asarray(m['CentersXY'])[:, :1] +
                4.75 * np.arange(60) / m['SourceProfile']['PixelSize'] + .5)
        assert np.array_equal(center_x, expected_x) and np.array_equal(center_y, expected_y)
        expected_fraction = np.zeros_like(fraction)
        windows = [(40,60),(65,85),(110,130),(145,165),(195,215),(245,265)]
        if m['Case'] != 'smooth_pairs':
            windows = [] if m['Case'] == 'control' else [(100,160)]
        for a,b in windows:
            pulse = .2 * np.sin(np.pi*np.arange(1,b-a+1)/(b-a+1))**2
            expected_fraction[:, a:b] = np.array([-1,1])[:,None] * pulse
        if m['Case'] != 'single_noise':
            assert np.allclose(fraction, expected_fraction, atol=1e-14, rtol=0)
        else:
            assert np.all(fraction[:,:100] == 0) and np.all(fraction[:,160:] == 0)
            assert np.all(np.isfinite(fraction))
        assert m['RadiusUm'] == 85.5 and m['SampleHz'] == 1
        assert abs(m['RadiusPixels'] * m['SourceProfile']['PixelSize'] - 85.5) < 1e-10
        with Image.open(source) as original, Image.open(path.parent / 'challenge_original.tif') as generated:
            assert original.n_frames == generated.n_frames == m['Frames']
            for t in range(m['Frames']):
                original.seek(t)
                raw = np.asarray(original).astype(float)
                assert raw.shape == (m['Height'], m['Width'])
                factor = np.ones_like(raw)
                for k in range(2):
                    mask = (xx-center_x[k, t])**2+(yy-center_y[k, t])**2 <= m['RadiusPixels']**2
                    factor[mask] = 1 + fraction[k, t]
                unrounded = raw * factor
                generated.seek(t)
                actual = np.asarray(generated)
                assert actual.shape == raw.shape
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
              'SavedMotionLedgerVerified': True,
              'AnalyticMotionAndNoiseFreePulseVerified': True,
              'NoiseRNGRegeneratedIndependently': False}
    (root / 'input-verification.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root')
    verify(parser.parse_args().root)
