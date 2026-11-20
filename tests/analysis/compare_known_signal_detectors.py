"""Compare fixed full-input cases across an explicitly changed detector contract."""
import argparse
import csv
import json
import math
from pathlib import Path


def compare(old_root, new_root, output):
    old_root, new_root, output = map(Path, (old_root, new_root, output))
    old, new = [json.loads((p / 'manifest.json').read_text()) for p in (old_root, new_root)]
    for key in ('SourceSHA256', 'SourceFrames', 'SourceRows', 'SourceColumns', 'CircleCenterXY',
                'SampleHz', 'PixelSizeUm', 'CircleRadiusPixels', 'WindowsInclusive', 'Cases'):
        assert old[key] == new[key], f'Changed input design: {key}'
    assert old['PipelineContract']['Detector'] != new['PipelineContract']['Detector']
    assert old['PipelineContract']['Normalization'] == new['PipelineContract']['Normalization']
    keys = ('Case', 'DetectionSign', 'Window')

    def read(root):
        with (root / 'pilot-results.csv').open() as f:
            rows = list(csv.DictReader(f))
        result = {tuple(r[k] for k in keys): r for r in rows}
        assert len(result) == len(rows) == len(new['Cases']) * 2 * len(new['WindowsInclusive'])
        return result

    olds, news = read(old_root), read(new_root)
    assert olds.keys() == news.keys()
    rows = []
    for key, a in olds.items():
        b = news[key]
        assert math.isclose(float(a['ActualInjectedLocalFraction']), float(b['ActualInjectedLocalFraction']), abs_tol=1e-12)
        row = dict(zip(keys, key))
        for metric in ('BestNativeSpacetimeIoU', 'OverlappingEvents', 'TotalDetectedEvents',
                       'MeasuredOnsetErrorSec', 'MeasuredOffsetErrorSec', 'TimingResolved', 'MeasuredAmplitudeFraction'):
            row['Previous' + metric] = a[metric]
            row['Current' + metric] = b[metric]
        row['CurrentCloseNativeRun'] = b['CloseNativeRun']
        row['CurrentBaselineStatus'] = b['BaselineStatus']
        rows.append(row)
    output.mkdir(parents=True, exist_ok=True)
    with (output / 'detector-comparison.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]), lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)
    result = {'InputDesignMatches': True, 'RowsCompared': len(rows),
              'PreviousContract': old['PipelineContract'], 'CurrentContract': new['PipelineContract']}
    (output / 'detector-comparison-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('old_root')
    parser.add_argument('new_root')
    parser.add_argument('output')
    args = parser.parse_args()
    compare(args.old_root, args.new_root, args.output)
