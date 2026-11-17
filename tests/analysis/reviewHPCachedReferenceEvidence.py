"""Audit cached HP reference availability and geometry, without source decisions.

This reads the preserved inventory, frame metadata and staged BOI TIFF. It does
not inspect unavailable reference pixels, infer registration or create a mask.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

from PIL import Image


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cached_input_root", type=Path)
    parser.add_argument("output_root", type=Path)
    args = parser.parse_args()
    root = args.cached_input_root.resolve()
    out = args.output_root.resolve()
    if out == root or root in out.parents:
        raise ValueError("Preserve the cached input record; use a separate output root.")
    inventory_file = root / "inventory/inventory.json"
    metadata_file = root / "inventory/selected-frame-metadata.json"
    inventory = json.loads(inventory_file.read_text())
    metadata = json.loads(metadata_file.read_text())
    assert digest(metadata_file) == inventory["selected_frame_metadata_sha256"]
    selected = [r for r in inventory["records"] if r["csv_line"] == 2]
    assert len(selected) == 1
    selected = selected[0]
    assert selected["original_csv_row"]["Paths"] == r"Data\GFAP-ECS-GeNL\FB2412"
    assert len(selected["source_candidates"]) == 1
    candidate = selected["source_candidates"][0]
    source = root / "Recording" / Path(candidate["path"]).name
    expected = "3d903105aa450da0348d6aa4ddb4b23145099534d5817a826461bb5ff2132e73"
    assert digest(source) == candidate["sha256"] == metadata["sha256"] == expected
    frames = metadata["frames"]
    assert [f["page_one_based"] for f in frames] == list(range(1, 1201))
    for i, frame in enumerate(frames):
        assert frame["original_tag_51123"]["FrameIndex"] == i
    keys = ["Width", "Height", "ROI", "Binning", "PixelSizeUm", "PixelSizeAffine",
            "Andor-TransposeCorrection", "Andor-TransposeXY",
            "Andor-TransposeMirrorX", "Andor-TransposeMirrorY", "Core-ImageProcessor",
            "PositionIndex", "SliceIndex", "ChannelIndex", "Andor-Camera"]
    geometry = {}
    for key in keys:
        observed = Counter(json.dumps(f["original_tag_51123"].get(key), sort_keys=True)
                           for f in frames)
        geometry[key] = [{"recorded_value": json.loads(value), "frame_count": count}
                         for value, count in sorted(observed.items())]
    with Image.open(source) as image:
        decoded = {"rows": image.height, "columns": image.width, "frames": image.n_frames,
                   "orientation_tag_as_recorded": image.tag_v2.get(274),
                   "software_tag_as_recorded": image.tag_v2.get(305)}
    references = [{"csv_line": r["csv_line"],
                   "mouse_as_csv": r["original_csv_row"]["Mouse"],
                   "folder_as_csv": r["original_csv_row"]["Paths"],
                   "reference_paths_from_cached_inventory": r["auxiliary_tiff_paths_not_analyzed"],
                   "reference_pixels_inspected_in_this_review": False}
                  for r in inventory["records"]]
    report = {
        "schema": "boi-cached-reference-review-1",
        "decision_id": "R1-HP-REFERENCE-005",
        "recorded_utc": datetime.now(timezone.utc).isoformat(),
        "status": "cached_evidence_review_complete_reference_pixel_review_pending",
        "recording_id": "HP_ECS_CSV2_identity_pending",
        "volume_available_at_review": Path("/Volumes/extZCM361_2").is_dir(),
        "evidence": {"inventory_sha256": digest(inventory_file),
                     "inventory_recorded_utc": inventory["recorded_utc"],
                     "frame_metadata_sha256": digest(metadata_file), "source_sha256": expected,
                     "script_sha256": digest(Path(__file__))},
        "inventory_scope": "TIFF/TIFF-extension names containing 490 or white directly inside each recording's New folder; not a recursive search of the external volume or all image formats",
        "records": references,
        "counts": {"csv_rows": len(references),
                   "rows_with_named_references": sum(bool(r["reference_paths_from_cached_inventory"]) for r in references),
                   "named_reference_files": sum(len(r["reference_paths_from_cached_inventory"]) for r in references)},
        "selected_recording_named_references": selected["auxiliary_tiff_paths_not_analyzed"],
        "decoded_source": decoded,
        "source_geometry_as_recorded": geometry,
        "interpretation": [
            "No named reference was inventoried for the selected FB2412 folder within the stated search scope; this does not establish absence elsewhere.",
            "The FB2413 490 nm reference is a different folder association. An embedded FB2412 prefix does not establish a match to the selected recording.",
            "Constant camera ROI/binning/transpose declarations describe recorded settings, not proof of anatomical registration or absence of prior processing.",
            "Zero PixelSizeUm and all-zero affine metadata provide no usable physical calibration or registration transform.",
            "Decoded row/column coordinates remain the native mask coordinate system; anatomy and dynamic tissue validity are not established.",
            "User-confirmed external 1 Hz timing remains authoritative. Embedded timestamps are not used to derive sampling or match references."
        ],
        "reference_images_read": 0,
        "mask_adopted": False,
        "detector_reruns": 0,
        "scientific_eligibility": "not_established",
        "next_required_evidence": "Access to the external volume and a demonstrably matching anatomical/observable-support reference, including alignment evidence. Search beyond the earlier narrow inventory before asserting absence."
    }
    out.mkdir(parents=True, exist_ok=False)
    (out / "reference-review.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"status": report["status"], "counts": report["counts"],
                      "selected_named_references": report["selected_recording_named_references"],
                      "volume_available": report["volume_available_at_review"]}, indent=2))


if __name__ == "__main__":
    main()
