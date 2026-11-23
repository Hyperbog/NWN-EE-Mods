"""Reconstruct the committed EFP source and verify its native package."""
import hashlib
import json
import pathlib
import re
import shutil
import struct
import subprocess
import sys
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src/first-person"
PLAN = json.loads((SRC / "BUILD_PLAN.json").read_text(encoding="utf-8"))
CX = ROOT / "cx-build"
DLLS = ("version.dll", "cx_openal.dll", "phonon.dll", "shaderc_shared.dll", "vma.dll")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", "-C", str(CX), *args], text=True).strip()


def reconstruct():
    assert git("rev-parse", "HEAD") == PLAN["base"], "Wrong CX checkpoint"
    manifest = json.loads((SRC / "SOURCE_MANIFEST.json").read_text(encoding="utf-8"))
    assert manifest["local_checkpoint"] == PLAN["base"], "Manifest base differs"
    for name, entry in manifest["modules"].items():
        assert re.fullmatch(r"managed/[A-Za-z0-9_./-]+\.cs", name)
        assert ".." not in pathlib.PurePosixPath(name).parts
        data = (SRC / name).read_bytes().decode("utf-8-sig").replace("\r\n", "\n").encode("utf-8")
        assert sha(data) == entry["published_sha256_lf"], f"Overlay hash mismatch: {name}"
        dest = CX / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
    for rel in PLAN["patches"]:
        assert re.fullmatch(r"M[0-9]+/[A-Za-z0-9_.-]+\.patch", rel)
        patch = SRC / "milestones" / rel
        git("apply", "--check", str(patch))
        git("apply", str(patch))
    print("Verified overlay and applied", PLAN["patches"])


def verify():
    source_zip = CX / "cx-windows-x64.zip"
    dist = ROOT / "dist"
    dist.mkdir(exist_ok=False)
    version = PLAN["version"]
    assert re.fullmatch(r"M[0-9]+(?:-[A-Za-z0-9]+)?", version)
    package = dist / f"NWN-EFP-{version}-win-x64.zip"
    with zipfile.ZipFile(source_zip) as archive:
        names = archive.namelist()
        hashes = {}
        for name in DLLS:
            assert names.count(name) == 1, f"Missing or duplicate: {name}"
            data = archive.read(name)
            assert data == (CX / "cx-windows-x64" / name).read_bytes(), name
            assert data[:2] == b"MZ", name
            pe = struct.unpack_from("<I", data, 0x3C)[0]
            assert data[pe:pe + 4] == b"PE\0\0", name
            assert struct.unpack_from("<H", data, pe + 4)[0] == 0x8664, name
            hashes[name] = {"sha256": sha(data), "size_bytes": len(data)}
    shutil.copyfile(source_zip, package)
    result = {
        "version": version,
        "mod_source_commit": subprocess.check_output(
            ["git", "-C", str(ROOT), "rev-parse", "HEAD"], text=True
        ).strip(),
        "cx_checkpoint": PLAN["base"],
        "patches": PLAN["patches"],
        "package": package.name,
        "package_sha256": sha(package.read_bytes()),
        "dlls": hashes,
        "status": "NativeAOT package integrity verified; in-game testing pending"
    }
    (dist / "release-manifest.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    (dist / "SHA256SUMS").write_text(
        f'{result["package_sha256"]}  {package.name}\n', encoding="ascii"
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    if sys.argv[1:] == ["stage"]:
        reconstruct()
    elif sys.argv[1:] == ["package"]:
        verify()
    else:
        raise SystemExit("Usage: cloud_build.py stage|package")
