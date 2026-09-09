"""Rebuild imposed pixels, audit saved masks and recalculate source-weight scores.

This does not independently re-segment the images. Run from the repository root
with NumPy, Pillow and h5py available.
"""
import argparse
import csv
import hashlib
import json
import time
from contextlib import ExitStack
from pathlib import Path
import numpy as np
from PIL import Image

SESSIONS = ('M400-01-baseline-awake', 'M401-01-baseline-awake',
            'FB2312-baseline-awake', 'FB2411')
RECIPES = ('separate_pair', 'approach_pair', 'crossing_pair', 'single_expanding')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(path):
    value = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(8 * 1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def rows(path):
    with Path(path).open(newline='') as stream:
        return list(csv.DictReader(stream))


def weights(h, w, f, pixel, recipe):
    require(recipe in RECIPES, 'Unknown recipe')
    k = 1 if recipe == 'single_expanding' else 2
    result = np.zeros((h, w, k))
    if not 101 <= f <= 180:
        return result
    u = (f - 101) / 79
    offset, sigma = 160., 60.
    if recipe == 'approach_pair':
        offset -= 100 * np.sin(np.pi * u)**2
    if recipe == 'crossing_pair':
        offset *= 1 - 2 * u
    if k == 1:
        offset, sigma = 0., 40 + 50 * np.sin(np.pi * u)**2
    cy, cx = np.floor(h/2 + .5), np.floor(w/2 + .5)
    yy, xx = np.mgrid[1:h+1, 1:w+1]
    for j, center in enumerate((cx - offset/pixel, cx + offset/pixel)[:k]):
        require(center-3*sigma/pixel >= 1 and center+3*sigma/pixel <= w
                and cy-3*sigma/pixel >= 1 and cy+3*sigma/pixel <= h, 'Truncated image boundary')
        d2 = ((xx-center)*pixel)**2 + ((yy-cy)*pixel)**2
        result[:, :, j] = (.20, .16)[j] * np.sin(np.pi*(f-100)/81)**2 * np.exp(-d2/(2*sigma**2)) * (d2 <= (3*sigma)**2)
    return result


def check_scores(mass_rows, score_rows, recipe):
    k = 1 if recipe == 'single_expanding' else 2
    require(len(score_rows) == k and {int(s['RecipeSource']) for s in score_rows} == set(range(1, k+1)), 'Score source matrix')
    ids = [int(r['CandidateRunID']) for r in mass_rows]
    require(len(ids) == len(set(ids)), 'Duplicate mass IDs')
    coverage = np.zeros((len(ids), k))
    mass = np.zeros_like(coverage)
    for j in range(k):
        totals = [float(r[f'Recipe{j+1}Total']) for r in mass_rows]
        require(not totals or (totals[0] > 0 and all(t == totals[0] for t in totals)), 'Invalid total mass')
        for a, row in enumerate(mass_rows):
            mass[a, j] = float(row[f'Recipe{j+1}Mass'])
            coverage[a, j] = float(row[f'Recipe{j+1}Coverage'])
            require(np.isfinite(mass[a, j]) and mass[a, j] >= 0, 'Invalid mass')
            require(np.isclose(coverage[a, j], mass[a, j]/totals[a], atol=1e-12, rtol=1e-10), 'Coverage arithmetic')
    require(np.all(coverage.sum(axis=0) <= 1+1e-10), 'Duplicated retained mass')
    used, assigned = set(), 0.
    for score in score_rows:
        j = int(score['RecipeSource'])-1
        rid = float(score['AssignedCandidateRunID'])
        cov = float(score['RecipeMassCoverage'])
        if np.isfinite(rid):
            require(rid in ids and rid not in used, 'Assignment reuses or invents a run')
            used.add(rid)
            a = ids.index(rid)
            require(np.isclose(cov, coverage[a, j], atol=1e-12), 'Assigned coverage mismatch')
            require(np.isclose(float(score['RecipeContributionFraction']), mass[a, j]/mass[a].sum(), atol=1e-12), 'Contribution arithmetic')
        else:
            require(cov == 0, 'Unmatched nonzero score')
        require(np.isclose(float(score['AllRetainedRecipeMassCoverage']), coverage[:, j].sum(), atol=1e-12), 'Union score mismatch')
        require(int(score['RunsCoveringAtLeastTenPercent']) == np.count_nonzero(coverage[:, j] >= .1), 'Fragment count mismatch')
        assigned += cov
    padded = np.vstack((coverage, np.zeros((2, k))))
    if k == 1:
        optimal = padded[:, 0].max()
    else:
        optimal = max(padded[a, 0]+padded[b, 1] for a in range(len(padded)) for b in range(len(padded)) if a != b)
    require(np.isclose(assigned, optimal, atol=1e-12), 'Assignment not optimal')


def read_pixels(handle, dataset):
    if dataset.attrs.get('MATLAB_empty', False):
        return np.empty(0, dtype=np.int64)
    data = np.asarray(dataset).ravel()
    require(np.all(np.isfinite(data)) and np.all(data == np.floor(data)) and np.all(data >= 1), 'Invalid mask pixel')
    return data.astype(np.int64)-1


def frame_candidates(handle, collection, frame):
    import h5py
    obj = handle[handle[collection][0, frame]]
    if not isinstance(obj, h5py.Group):
        require(obj.attrs.get('MATLAB_empty', False), 'Malformed empty candidates')
        return []
    field = obj['PixelIdxList']
    if field.dtype.kind == 'O':
        return [read_pixels(handle, handle[ref]) for ref in field[()].ravel()]
    return [read_pixels(handle, field)]


def audit_masks_and_mass(path, m):
    import h5py
    recipes = RECIPES if m['Case'] == 'source_control' else (m['Case'],)
    n, h, w = m['Frames'], m['Height'], m['Width']
    totals = {r: np.zeros(1 if r == 'single_expanding' else 2) for r in recipes}
    with ExitStack() as stack:
        candidates = stack.enter_context(h5py.File(path.parent/'candidate-input.mat'))
        source = stack.enter_context(Image.open(m['SourceTiff']))
        runs, kept, matrices = {}, {}, {}
        for method in ('native', 'partition'):
            runs[method] = stack.enter_context(h5py.File(path.parent/f'{method}-runs.mat'))
            q = rows(path.parent/f'{method}-runs.csv')
            require(runs[method]['R'].shape == (n, len(q)), 'Run matrix dimensions')
            kept[method] = [(i, row) for i, row in enumerate(q) if row['KeptAsEvent'] in ('1', 'true')]
            matrices[method] = {r: np.zeros((len(kept[method]), len(totals[r]))) for r in recipes}
        for f in range(n):
            groups = {method: frame_candidates(candidates, name, f)
                      for method, name in (('native', 'C'), ('partition', 'Separated'))}
            unions = {}
            for method, group in groups.items():
                all_pixels = np.concatenate(group) if group else np.empty(0, dtype=np.int64)
                require(np.all(all_pixels < h*w), 'Out-of-image candidate')
                unions[method] = np.sort(all_pixels)
                require(len(np.unique(all_pixels)) == len(all_pixels), 'Candidate pixel duplication')
            require(np.array_equal(unions['native'], unions['partition']), 'Partition lost or added pixels')
            imposed = {}
            if 100 <= f < 180:
                source.seek(f); raw = np.asarray(source, dtype=float)
                for recipe in recipes:
                    imposed[recipe] = weights(h, w, f+1, m['SourceProfile']['PixelSize'], recipe)*raw[:, :, None]
                    totals[recipe] += imposed[recipe].sum(axis=(0, 1))
            for method in runs:
                lookup = {int(p.min()): p for p in groups[method] if len(p)}
                handle = runs[method]
                for a, (i, row) in enumerate(kept[method]):
                    pixels = read_pixels(handle, handle[handle['R'][f, i]])
                    within = int(row['NativeStartFrame']) <= f+1 <= int(row['NativeEndFrame'])
                    require(bool(len(pixels)) == within, 'Retained run has a gap or exceeds its native bounds')
                    if len(pixels):
                        require(int(pixels.min()) in lookup and np.array_equal(np.sort(pixels), np.sort(lookup[int(pixels.min())])), 'Run mask is not an admitted candidate')
                        for recipe, increment in imposed.items():
                            for k in range(increment.shape[2]):
                                matrices[method][recipe][a, k] += increment[:, :, k].ravel(order='F')[pixels].sum()
        for method in runs:
            ids = [i+1 for i, _ in kept[method]]
            for recipe in recipes:
                exported = rows(path.parent/f'{method}-{recipe}-mass.csv')
                require([int(r['CandidateRunID']) for r in exported] == ids, 'Mass rows do not match retained run IDs')
                for a, row in enumerate(exported):
                    for k, total in enumerate(totals[recipe], 1):
                        require(np.isclose(float(row[f'Recipe{k}Total']), total, atol=1e-6, rtol=1e-10), 'Independent total mass mismatch')
                        require(np.isclose(float(row[f'Recipe{k}Mass']), matrices[method][recipe][a, k-1], atol=1e-6, rtol=1e-10), 'Independent mask mass mismatch')


def verify(root, watch=False):
    root = Path(root)
    manifests = [root/s/c/'challenge-manifest.json' for s in SESSIONS for c in ('source_control',)+RECIPES]
    expected = {(s, c) for s in SESSIONS for c in ('source_control',)+RECIPES}
    seen, hashes, pixels, ties = set(), {}, 0, 0
    deadline = time.monotonic()+3600
    for path in manifests:
        if watch:
            while True:
                ready = rows(root/'separation-summary.csv') if (root/'separation-summary.csv').exists() else []
                ready = [r for r in ready if r.get('Session') == path.parent.parent.name and r.get('Case') == path.parent.name]
                available = rows(root/'recipe-scores.csv') if (root/'recipe-scores.csv').exists() else []
                available = [r for r in available if r.get('Session') == path.parent.parent.name and r.get('Case') == path.parent.name]
                needed = 14 if path.parent.name == 'source_control' else (2 if path.parent.name == 'single_expanding' else 4)
                if {r.get('Method') for r in ready} == {'native', 'partition'} and len(available) == needed:
                    break
                require(time.monotonic() < deadline, 'Timed out waiting for complete movie outputs')
                time.sleep(2)
        scores = rows(root/'recipe-scores.csv')
        m = json.loads(path.read_text())
        key = m['Session'], m['Case']
        require(key in expected and key not in seen, 'Unexpected/duplicate movie')
        seen.add(key)
        require(m['RecipeVersion'] == 'gaussian-contact-1' and m['Window'] == [101, 180], 'Wrong protocol')
        source, actual = Path(m['SourceTiff']), Path(m['InputTiff'])
        reference = json.loads((source.parent.parent/'reference-report.json').read_text())
        require(m['SourceProfile'] == reference['Profile'] and m['SourceProfile']['Session'] == m['Session']
                and m['SourceSHA256'] == reference['Conversion']['TiffSHA256'], 'Reference metadata mismatch')
        require(m['Options']['MinimumHistorySec'] == 3
                and np.isclose(m['Options']['MinimumMarkerDistanceUm'], 2*np.sqrt(9025/np.pi), rtol=0, atol=1e-10)
                and m['Options']['MinimumSaddleDropFraction'] == .2, 'Changed partition protocol')
        for file, digest in ((source, m['SourceSHA256']), (actual, m['InputSHA256'])):
            if str(file) not in hashes:
                hashes[str(file)] = sha(file)
            require(hashes[str(file)] == digest, 'Input hash mismatch')
        require(m['SourceProfile']['SampleHz'] == 1, 'Wrong acquisition rate')
        with Image.open(source) as original, Image.open(actual) as challenge:
            require(original.n_frames == challenge.n_frames == m['Frames'], 'Frame count')
            require(original.size == challenge.size == (m['Width'], m['Height']), 'Image dimensions')
            if m['Case'] != 'source_control':
                for t in range(m['Frames']):
                    original.seek(t); challenge.seek(t)
                    raw = np.asarray(original, dtype=float)
                    signal = weights(*raw.shape, t+1, m['SourceProfile']['PixelSize'], m['Case'])
                    unrounded = raw*(1+signal.sum(axis=2))
                    require(unrounded.min() >= 0 and unrounded.max() <= 65535, 'Clipped injection')
                    got = np.asarray(challenge)
                    expected_pixels = np.floor(unrounded+.5).astype(np.uint16)
                    mismatch = got != expected_pixels
                    if np.any(mismatch):
                        require(np.all(np.abs(unrounded[mismatch]-got[mismatch]) <= .500000001)
                                and np.all(np.abs(unrounded[mismatch] % 1-.5) < 1e-9), 'Recipe pixel mismatch')
                        ties += int(mismatch.sum())
                    pixels += got.size
            else:
                require(m['InputSHA256'] == m['SourceSHA256'], 'Changed source control')
        for method in ('native', 'partition'):
            for recipe in RECIPES if m['Case'] == 'source_control' else (m['Case'],):
                subset = [s for s in scores if (s['Session'], s['Case'], s['Method'], s['Recipe']) == (*key, method, recipe)]
                check_scores(rows(path.parent/f'{method}-{recipe}-mass.csv'), subset, recipe)
        audit_masks_and_mass(path, m)
        print('VERIFIED', *key, flush=True)
    require(seen == expected, 'Incomplete movie matrix')
    require(len(list(root.glob('*/*/challenge-manifest.json'))) == 20, 'Unexpected movie manifests')
    scores = rows(root/'recipe-scores.csv')
    require(len(scores) == 112, 'Expected 112 source-score rows')
    score_keys = [(s['Session'], s['Case'], s['Method'], s['Recipe'], int(s['RecipeSource'])) for s in scores]
    require(len(set(score_keys)) == len(score_keys), 'Duplicate score identity')
    completion = json.loads((root/'completion.json').read_text())
    require(completion['CompleteMovieEvaluations'] == 20 and completion['ScoreRows'] == 112
            and completion['CodeFreezeVerified'] and completion['MasterStatisticsReruns'] == 0, 'Incomplete run')
    report = dict(ChallengeMoviesVerified=16, UnchangedControlsVerified=4, PixelsVerified=pixels,
                  ToleratedHalfCountRoundingTies=ties, ScoreRowsVerified=112,
                  IndependentMaskMembershipRecalculation=True, FullFramePixelConservationVerified=True,
                  IndependentImageSegmentation=False)
    (root/'independent-verification.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root')
    parser.add_argument('--watch', action='store_true', help='Verify each movie after the active MATLAB run exports it (one-hour timeout).')
    args = parser.parse_args()
    verify(args.root, args.watch)
