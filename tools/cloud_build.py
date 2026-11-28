"""Check out pinned EFP source and verify native packages."""
import hashlib
import json
import pathlib
import re
import struct
import subprocess
import sys
import tempfile
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


UPSTREAM_MEMBERS = DLLS + ("README.txt", "LICENSES.txt")
FINAL_MEMBERS = UPSTREAM_MEMBERS + ("LICENSE-EFP.txt", "THIRD_PARTY_NOTICES.md")


def read_archive(path, expected):
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
        if sorted(names) != sorted(expected):
            raise ValueError(f"Invalid archive inventory in {path}: {names}")
        return {name: archive.read(name) for name in expected}


def required_bytes(path):
    data = path.read_bytes()
    if not data.strip():
        raise ValueError(f"Empty required file: {path}")
    return data


def check_pe(name, data):
    if len(data) < 64 or data[:2] != b"MZ":
        raise ValueError(f"Invalid DOS header: {name}")
    pe = struct.unpack_from("<I", data, 0x3C)[0]
    if pe < 64 or pe + 6 > len(data) or data[pe:pe + 4] != b"PE\0\0":
        raise ValueError(f"Invalid PE header: {name}")
    if struct.unpack_from("<H", data, pe + 4)[0] != 0x8664:
        raise ValueError(f"Not x64: {name}")


def verify():
    pin = check_direct_pin()
    version = PLAN["version"]
    if not re.fullmatch(r"M[0-9]+(?:-[A-Za-z0-9]+)?", version):
        raise ValueError("Invalid package version")
    commit = subprocess.check_output(
        ["git", "-C", str(ROOT), "rev-parse", "HEAD"], text=True
    ).strip()
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ValueError("Invalid distribution commit")
    dist = ROOT / "dist"
    if dist.exists():
        raise FileExistsError(dist)
    members = read_archive(CX / "cx-windows-x64.zip", UPSTREAM_MEMBERS)
    for name, data in members.items():
        if data != required_bytes(CX / "cx-windows-x64" / name):
            raise ValueError(f"Staged bytes mismatch: {name}")
    for name in DLLS:
        check_pe(name, members[name])
    readme = required_bytes(SRC / "README-WINDOWS.txt").decode("utf-8")
    members["README.txt"] = readme.replace("@VERSION@", version).replace(
        "@SOURCE_COMMIT@", commit).encode("utf-8")
    members["LICENSE-EFP.txt"] = required_bytes(ROOT / "LICENSE")
    members["THIRD_PARTY_NOTICES.md"] = required_bytes(ROOT / "THIRD_PARTY_NOTICES.md")
    with tempfile.TemporaryDirectory(prefix=".efp-package-", dir=ROOT) as temp:
        stage = pathlib.Path(temp) / "dist"
        stage.mkdir()
        package = stage / f"NWN-EFP-{version}-win-x64.zip"
        with zipfile.ZipFile(package, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for name in FINAL_MEMBERS:
                archive.writestr(name, members[name])
        final = read_archive(package, FINAL_MEMBERS)
        for name, data in final.items():
            if data != members[name]:
                raise ValueError(f"Final archive bytes mismatch: {name}")
        hashes = {name: {"sha256": sha(final[name]), "size_bytes": len(final[name])}
                  for name in DLLS}
        result = write_manifest(stage, package, version, commit, pin, hashes)
        stage.rename(dist)
    print(json.dumps(result, indent=2))


def write_manifest(dist, package, version, commit, pin, hashes):
    result = {
        "version": version,
        "mod_source_commit": commit,
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
    return result


if __name__ == "__main__":
    if sys.argv[1:] == ["checkout"]:
        checkout_direct()
    elif sys.argv[1:] == ["package-direct"]:
        verify()
    else:
        raise SystemExit("Usage: cloud_build.py checkout|package-direct")
