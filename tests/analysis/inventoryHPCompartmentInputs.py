"""Read-only HP source/header inventory; never reads pixels or prior outcomes.

Run with the bundled Python (Pillow required), SOURCE_ROOT and a new OUTPUT_DIR.
The output is an evidence snapshot, not an executable cohort or eligibility list.
"""
import argparse
import csv
import hashlib
import io
import json
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image


def sha256(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def header(path):
    with Image.open(path) as im:
        info = {"width": im.width, "height": im.height, "frames": im.n_frames,
                "mode": im.mode, "image_description": im.tag_v2.get(270, ""),
                "resolution_tags_as_recorded": {str(k): str(im.tag_v2[k])
                    for k in (282, 283, 296) if k in im.tag_v2}}
        for k in (50839, 51123):
            value = im.tag_v2.get(k)
            if value is not None:
                data = value if isinstance(value, bytes) else str(value).encode()
                info[f"tag_{k}_sha256"] = hashlib.sha256(data).hexdigest()
        v = im.tag_v2.get(51123)
        if v:
            d = json.loads(v)
            info["first_page_acquisition"] = {k: d[k] for k in (
                "Frame", "FrameIndex", "Exposure-ms", "ElapsedTime-ms", "ReceivedTime",
                "PixelSizeUm", "Binning", "Camera", "Andor-Trigger", "Andor-Exposure",
                "Andor-ActualInterval-ms") if k in d}
        # ImageJ stores its Info text as UTF-16 after a binary metadata header.
        # Keep only a parseable JSON object; do not infer any acquisition value.
        raw = im.tag_v2.get(50839, b"")
        if isinstance(raw, bytes):
            offset = raw.find(b"{\x00")
            if offset >= 0:
                try:
                    d, _ = json.JSONDecoder().raw_decode(raw[offset:].decode("utf-16-le", errors="replace"))
                    info["embedded_summary_fields"] = {k: d[k] for k in (
                        "Prefix", "Interval_ms", "Frames", "Channels", "Slices",
                        "StartTime", "AxisOrder") if k in d}
                except (ValueError, TypeError):
                    info["embedded_summary_parse_status"] = "not_parsed"
        return info


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_root", type=Path)
    parser.add_argument("output_dir", type=Path)
    args = parser.parse_args()
    root, out = args.source_root.resolve(), args.output_dir.resolve()
    if out == root or root in out.parents:
        raise ValueError("Evidence output must be outside the source tree.")
    out.mkdir(parents=True, exist_ok=False)
    repo = Path(__file__).resolve().parents[2]
    ledger_path = repo / "docs/planning/boi-cohort-20260910.json"
    ledger = json.loads(ledger_path.read_text())
    metadata = root / "HP_Compartments.csv"
    csv_hash = sha256(metadata)
    original_text = metadata.read_text(encoding="utf-8-sig")
    rows = list(csv.DictReader(io.StringIO(original_text)))
    records = []
    for line, row in enumerate(rows, 2):
        parts = row["Paths"].split("\\")
        assert parts[0] == "Data" and ".." not in parts
        folder = root.joinpath(*parts[1:])
        candidates = []
        auxiliary = []
        for p in sorted((folder / "New folder").glob("*")):
            if p.is_file() and p.suffix.lower() in (".tif", ".tiff"):
                if any(token in p.name.lower() for token in ("490", "white")):
                    auxiliary.append(str(p.relative_to(root)))
                else:
                    candidates.append(p)
        matches = [r for r in ledger["recordings"] if r["mouse"] == row["Mouse"]]
        record = {"csv_line": line, "original_csv_row": row, "resolved_folder": str(folder),
                  "folder_exists": folder.is_dir(), "archive_mouse_links": [
                      {k: r[k] for k in ("asset_id", "session", "selected_image_series")} for r in matches],
                  "archive_equivalence": "not_established; ID/name matches are not pixel equivalence",
                  "source_candidates": [], "auxiliary_tiff_paths_not_analyzed": auxiliary,
                  "top_level_tiffs": [{"path": str(p.relative_to(root)), "bytes": p.stat().st_size}
                      for p in sorted(folder.glob("*")) if p.is_file() and p.suffix.lower() in (".tif", ".tiff")],
                  "acquisition_files": [str(p.relative_to(root)) for p in sorted(folder.rglob("*.abf"))],
                  "role": "unassigned_not_eligible_not_untouched_evaluation"}
        for p in candidates:
            item = {"path": str(p.relative_to(root)), "bytes": p.stat().st_size,
                    "header": header(p), "exact_archive_series_name_matches": [
                        r["asset_id"] for r in ledger["recordings"] if r["selected_image_series"] == p.name]}
            record["source_candidates"].append(item)
        records.append(record)
    selected = next(r for r in records if r["original_csv_row"]["Paths"] == r"Data\GFAP-ECS-GeNL\FB2412")
    assert len(selected["source_candidates"]) == 1
    selected["role"] = "R1-HP-INPUT-001_development_input_transfer_check"
    source = root / selected["source_candidates"][0]["path"]
    frame_metadata = []
    with Image.open(source) as im:
        for i in range(im.n_frames):
            im.seek(i)
            d = json.loads(im.tag_v2[51123])
            assert d["FrameIndex"] == i and d["Frame"] == i
            frame_metadata.append({"page_one_based": i + 1, "original_tag_51123": d})
    elapsed = [r["original_tag_51123"]["ElapsedTime-ms"] / 1000 for r in frame_metadata]
    differences = [b-a for a, b in zip(elapsed, elapsed[1:])]
    assert all(d > 0 for d in differences)
    movie_hash = sha256(source)
    selected["source_candidates"][0]["sha256"] = movie_hash
    frames_path = out / "selected-frame-metadata.json"
    frames_path.write_text(json.dumps({"source_path": str(source), "sha256": movie_hash,
                                     "frames": frame_metadata}, indent=2) + "\n")
    report = {"schema": "boi-hp-source-inventory-1", "recorded_utc": datetime.now(timezone.utc).isoformat(),
              "source_root": str(root), "metadata_path": str(metadata), "metadata_sha256": csv_hash,
              "original_csv_text": original_text, "archive_ledger_sha256": sha256(ledger_path),
              "inventory_script_sha256": sha256(Path(__file__)),
              "method": "Pillow TIFF headers only; no image pixels or existing outcome files read. Only selected source TIFF fully hashed. Nonselected file sizes/header hashes do not establish whole-file identity.",
              "counts": {"csv_rows": len(rows), "folders_found": sum(r["folder_exists"] for r in records),
                  "mouse_ids_also_in_archive": sum(bool(r["archive_mouse_links"]) for r in records),
                  "source_candidates": sum(len(r["source_candidates"]) for r in records)},
              "records": records, "selected_frame_metadata_file": str(frames_path),
              "selected_frame_metadata_sha256": sha256(frames_path),
              "selected_timing": {"frames": len(elapsed), "first_elapsed_sec": elapsed[0],
                  "last_elapsed_sec": elapsed[-1], "min_adjacent_interval_sec": min(differences),
                  "max_adjacent_interval_sec": max(differences),
                  "max_abs_deviation_from_1Hz_sec": max(abs(t-elapsed[0]-i) for i,t in enumerate(elapsed)),
                  "interpretation": "Per-page Micro-Manager elapsed clock; exposure-start semantics and trigger alignment unverified. Not approved experimental windows."},
              "source_csv_unchanged_after_read": sha256(metadata) == csv_hash}
    assert report["source_csv_unchanged_after_read"]
    (out / "inventory.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"counts": report["counts"], "selected_timing": report["selected_timing"],
                      "inventory": str(out / "inventory.json")}, indent=2))


if __name__ == "__main__":
    main()
