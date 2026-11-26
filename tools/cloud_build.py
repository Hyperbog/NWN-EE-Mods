"""Check out pinned EFP source and verify native packages."""
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


def direct_pin():
    pin = PLAN["direct_source"]
    if pin["repository"] != "Hyperbog/cx":
        raise ValueError("Unexpected source repository")
    for field in ("commit", "tree"):
        if not re.fullmatch(r"[0-9a-f]{40}", pin[field]):
            raise ValueError(f"Invalid source {field}")
    return pin


def check_direct_pin():
    pin = direct_pin()
    if git("rev-parse", "HEAD") != pin["commit"]:
        raise RuntimeError("Wrong direct CX commit")
    if git("rev-parse", "HEAD^{tree}") != pin["tree"]:
        raise RuntimeError("Wrong direct CX tree")
    if git("remote", "get-url", "origin") != "https://github.com/Hyperbog/cx.git":
        raise RuntimeError("Wrong direct CX remote")
    return pin


def checkout_direct():
    pin = direct_pin()
    CX.mkdir(exist_ok=False)
    def run(*args):
        subprocess.run(["git", "-C", str(CX), *args], check=True)
    run("init")
    run("config", "core.autocrlf", "false")
    run("remote", "add", "origin", "https://github.com/Hyperbog/cx.git")
    run("fetch", "--no-tags", "origin", pin["commit"])
    run("checkout", "--detach", pin["commit"])
    check_direct_pin()
    run("submodule", "update", "--init", "--recursive")
    statuses = subprocess.check_output(
        ["git", "-C", str(CX), "submodule", "status", "--recursive"], text=True
    ).splitlines()
    if not statuses or any(not line.startswith(" ") for line in statuses):
        raise RuntimeError("Missing, mismatched or conflicted submodule")
    if git("status", "--porcelain", "--untracked-files=all", "--ignore-submodules=none"):
        raise RuntimeError("Direct source checkout is not clean")
    print("Direct source commit:", pin["commit"], "tree:", pin["tree"])
    print("\n".join(statuses))


def verify():
    pin = check_direct_pin()
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
        "patches": [],
        "package": package.name,
        "package_sha256": sha(package.read_bytes()),
        "dlls": hashes,
        "status": "NativeAOT package integrity verified; in-game testing pending"
    }
    result.update({
        "build_mode": "direct",
        "cx_source_repository": pin["repository"],
        "cx_source_commit": pin["commit"],
        "cx_source_tree": pin["tree"],
    })
    (dist / "release-manifest.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    (dist / "SHA256SUMS").write_text(
        f'{result["package_sha256"]}  {package.name}\n', encoding="ascii"
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    if sys.argv[1:] == ["checkout"]:
        checkout_direct()
    elif sys.argv[1:] == ["package-direct"]:
        verify()
    else:
        raise SystemExit("Usage: cloud_build.py checkout|package-direct")
