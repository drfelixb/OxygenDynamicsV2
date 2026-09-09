"""Compare paired pilot results only after verifying identical source injections."""
import argparse
import csv
import json
import math
from pathlib import Path


def compare(crop_root, full_root, output):
    crop_root, full_root, output = map(Path, (crop_root, full_root, output))
    a, b = [json.loads((p / 'manifest.json').read_text()) for p in (crop_root, full_root)]
    for key in ('SourceSHA256', 'SampleHz', 'PixelSizeUm', 'CircleRadiusPixels', 'Cases', 'PipelineContract'):
        assert a[key] == b[key], f'Mismatched {key}'
    for axis, bounds in ((0, 'SourceColumns'), (1, 'SourceRows')):
        assert a['CircleCenterXY'][axis] + a[bounds][0] == b['CircleCenterXY'][axis] + b[bounds][0]
    assert [[t + a['SourceFrames'][0] for t in w] for w in a['WindowsInclusive']] == [
        [t + b['SourceFrames'][0] for t in w] for w in b['WindowsInclusive']]
    keys = ('Case', 'DetectionSign', 'Window')

    def read(root):
        with (root / 'pilot-results.csv').open() as f:
            rows = list(csv.DictReader(f))
        result = {tuple(r[k] for k in keys): r for r in rows}
        assert len(rows) == len(result) == len(a['Cases']) * 2 * len(a['WindowsInclusive'])
        return result

    crops, fulls = read(crop_root), read(full_root)
    assert crops.keys() == fulls.keys()
    rows = []
    for key, crop in crops.items():
        full = fulls[key]
        assert math.isclose(float(crop['ActualInjectedLocalFraction']), float(full['ActualInjectedLocalFraction']), abs_tol=1e-12)
        row = dict(zip(keys, key))
        for metric in ('BestNativeSpacetimeIoU', 'OverlappingEvents', 'TotalDetectedEvents',
                       'MeasuredOnsetErrorSec', 'MeasuredOffsetErrorSec', 'TimingResolved'):
            row['Crop' + metric] = crop[metric]
            row['Full' + metric] = full[metric]
        rows.append(row)
    output.mkdir(parents=True, exist_ok=True)
    with (output / 'crop-full-comparison.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    result = {'SourceInjectionsAndSettingsMatch': True, 'RowsCompared': len(rows)}
    (output / 'comparison-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('crop_root')
    parser.add_argument('full_root')
    parser.add_argument('output')
    args = parser.parse_args()
    compare(args.crop_root, args.full_root, args.output)
