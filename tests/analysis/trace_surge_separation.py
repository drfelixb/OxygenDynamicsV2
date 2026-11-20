"""Explain partition decisions at the two prescribed Gaussian peak locations.

These are optical recipe locations, not physiological labels. Run after the
full separation experiment from the repository root; requires h5py and NumPy.
"""
import argparse
import csv
import json
from collections import Counter
from pathlib import Path
import h5py
import numpy as np
from verify_surge_separation import SESSIONS, RECIPES, frame_candidates, require, rows, weights


def trace(root):
    root = Path(root)
    output, counts = [], Counter()
    for session in SESSIONS:
        for recipe in RECIPES[:3]:
            folder = root/session/recipe
            m = json.loads((folder/'challenge-manifest.json').read_text())
            decisions = {(int(r['Frame']), int(r['ParentCandidateIndex'])): r
                         for r in rows(folder/'partition-decisions.csv')}
            with h5py.File(folder/'candidate-input.mat') as handle:
                for frame in range(101, 181):
                    groups = sorted(frame_candidates(handle, 'C', frame-1), key=lambda p: p.min())
                    labels = np.zeros(m['Height']*m['Width'], dtype=int)
                    for i, pixels in enumerate(groups, 1):
                        labels[pixels] = i
                    signal = weights(m['Height'], m['Width'], frame, m['SourceProfile']['PixelSize'], recipe)
                    peaks = [signal[:, :, k].ravel(order='F').argmax() for k in range(2)]
                    parents = [int(labels[p]) for p in peaks]
                    record = dict(Session=session, Case=recipe, Frame=frame,
                                  RecipePeak1Parent=parents[0], RecipePeak2Parent=parents[1],
                                  SupportState='', Outcome='', PreviousCandidates='NaN', MinimumPreviousHistoryFrames='NaN',
                                  MarkerDistanceUm='NaN', SaddleDropFraction='NaN')
                    if 0 in parents:
                        record['SupportState'] = 'one_or_both_recipe_peaks_outside_admitted_candidates'
                    elif parents[0] != parents[1]:
                        record['SupportState'] = 'recipe_peaks_in_separate_native_candidates'
                    else:
                        record['SupportState'] = 'recipe_peaks_in_one_native_candidate'
                        require((frame, parents[0]) in decisions, 'Missing parent decision')
                        d = decisions[frame, parents[0]]
                        for key in ('Outcome', 'PreviousCandidates', 'MinimumPreviousHistoryFrames', 'MarkerDistanceUm', 'SaddleDropFraction'):
                            record[key] = d[key]
                    output.append(record)
                    counts[session, recipe, record['SupportState'], record['Outcome']] += 1
    require(len(output) == 960, 'Incomplete twelve-case/eighty-frame trace')
    with (root/'recipe-peak-decisions.csv').open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(output[0]), lineterminator='\n')
        writer.writeheader(); writer.writerows(output)
    with (root/'recipe-peak-decision-counts.csv').open('w', newline='') as stream:
        writer = csv.writer(stream, lineterminator='\n')
        writer.writerow(('Session', 'Case', 'SupportState', 'Outcome', 'Frames'))
        writer.writerows((*key, value) for key, value in sorted(counts.items()))
    print('Traced 960 prescribed peak-location frames across twelve paired challenges.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root')
    trace(parser.parse_args().root)
