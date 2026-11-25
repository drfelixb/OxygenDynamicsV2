"""Check a release ZIP against a JSON-encoded getOxygenReleaseSourceList plan."""

import hashlib
import json
import sys
from pathlib import Path
from zipfile import ZipFile


def verify(archive, plan_path):
    plan = json.loads(Path(plan_path).read_text(encoding="utf-8"))
    sources = dict(zip(plan["RelativePaths"], plan["SHA256"]))
    manifest = "RELEASE_MANIFEST.txt"
    with ZipFile(archive) as package:
        files = [member.filename for member in package.infolist() if not member.is_dir()]
        expected = set(sources) | {manifest}
        if len(files) != len(expected) or set(files) != expected:
            missing = sorted(expected - set(files))
            extra = sorted(set(files) - expected)
            raise ValueError(f"ZIP inventory mismatch or duplicate member: missing={missing}, extra={extra}")
        for name, digest in sources.items():
            if hashlib.sha256(package.read(name)).hexdigest() != digest.lower():
                raise ValueError(f"SHA-256 mismatch for {name}")
        rows = [line for line in package.read(manifest).decode("utf-8").splitlines()
                if line.startswith("sha256\t")]
        if sorted(rows) != sorted(f"sha256\t{name}\t{digest}" for name, digest in sources.items()):
            raise ValueError("The generated manifest differs from the source inventory")
    print(f"Verified {len(sources)} source paths and hashes, plus {manifest}.")


if __name__ == "__main__":
    verify(*sys.argv[1:])
