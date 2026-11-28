"""Disposable package fixtures; run under ordinary Python and python -O."""
import contextlib
import io
import json
import pathlib
import shutil
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
import warnings
import zipfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
import cloud_build as build


class PackageTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = pathlib.Path(self.temp.name)
        self.cx = self.root / "cx-build"
        self.loose = self.cx / "cx-windows-x64"
        self.loose.mkdir(parents=True)
        self.src = self.root / "src/first-person"
        self.src.mkdir(parents=True)
        for name in ("LICENSE", "THIRD_PARTY_NOTICES.md"):
            shutil.copyfile(build.ROOT / name, self.root / name)
        shutil.copyfile(build.SRC / "README-WINDOWS.txt", self.src / "README-WINDOWS.txt")
        pe = bytearray(128)
        pe[:2] = b"MZ"
        struct.pack_into("<I", pe, 60, 64)
        struct.pack_into("<4sH", pe, 64, b"PE\0\0", 0x8664)
        self.members = {name: bytes(pe) + name.encode() for name in build.DLLS}
        self.members.update({"README.txt": b"obsolete upstream instructions",
                             "LICENSES.txt": b"upstream notices fixture\n"})
        for name, data in self.members.items():
            (self.loose / name).write_bytes(data)
        for name, value in (("ROOT", self.root), ("SRC", self.src), ("CX", self.cx)):
            self.enterContext(patch.object(build, name, value))
        self.enterContext(patch.object(build, "check_direct_pin", return_value=build.direct_pin()))
        self.enterContext(patch.object(build.subprocess, "check_output", return_value="a" * 40))

    def pack(self, extra=None):
        with zipfile.ZipFile(self.cx / "cx-windows-x64.zip", "w") as z:
            for name, data in self.members.items():
                z.writestr(name, data)
            if extra:
                with warnings.catch_warnings():
                    warnings.simplefilter("ignore", UserWarning)
                    z.writestr(extra, b"unexpected")
        with contextlib.redirect_stdout(io.StringIO()):
            build.verify()

    def reject(self, extra=None):
        with self.assertRaises((ValueError, FileNotFoundError)):
            self.pack(extra)
        self.assertFalse((self.root / "dist").exists())
        self.assertFalse(list(self.root.glob(".efp-package-*")))

    def test_valid(self):
        self.pack()
        dist = self.root / "dist"
        m = json.loads((dist / "release-manifest.json").read_text())
        z = dist / m["package"]
        self.assertEqual(m["package_sha256"], build.sha(z.read_bytes()))
        self.assertEqual((dist / "SHA256SUMS").read_text(), f'{m["package_sha256"]}  {z.name}\n')
        final = build.read_archive(z, build.FINAL_MEMBERS)
        for name in build.DLLS:
            self.assertEqual(final[name], self.members[name])
            self.assertEqual(m["dlls"][name], {"sha256": build.sha(final[name]), "size_bytes": len(final[name])})
        self.assertEqual(final["LICENSES.txt"], self.members["LICENSES.txt"])
        self.assertEqual(final["LICENSE-EFP.txt"], (self.root / "LICENSE").read_bytes())
        self.assertEqual(final["THIRD_PARTY_NOTICES.md"], (self.root / "THIRD_PARTY_NOTICES.md").read_bytes())
        readme = final["README.txt"].decode()
        for text in ("-SourceCommit " + "a" * 40, "-RestoreBackup", "All five existing CX DLLs",
                     "Do not extract", "Do not delete DLLs", "cx.cfg", "Hyperbog/NWN-EE-Mods/issues"):
            self.assertIn(text, readme)
        self.assertNotIn("@SOURCE_COMMIT@", readme)
        self.assertNotIn("obsolete upstream instructions", readme)

    def test_missing_loose(self):
        (self.loose / "version.dll").unlink()
        self.reject()

    def test_mismatched_loose(self):
        (self.loose / "version.dll").write_bytes(b"different")
        self.reject()

    def test_duplicate(self):
        self.reject("version.dll")

    def test_extra(self):
        self.reject("unknown.dll")

    def test_missing_member(self):
        del self.members["version.dll"]
        self.reject()

    def test_wrong_machine(self):
        data = bytearray(self.members["version.dll"])
        struct.pack_into("<H", data, 68, 0x14c)
        self.members["version.dll"] = bytes(data)
        (self.loose / "version.dll").write_bytes(data)
        self.reject()

    def test_missing_notices(self):
        (self.root / "THIRD_PARTY_NOTICES.md").unlink()
        self.reject()

    def test_missing_upstream_notices(self):
        del self.members["LICENSES.txt"]
        self.reject()


if __name__ == "__main__":
    unittest.main()
