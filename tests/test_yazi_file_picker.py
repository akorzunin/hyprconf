"""Picker setup regression checks: python -m unittest discover -s tests."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = "xdg-desktop-portal-termfilechooser-hunkyburrito-git"


class PickerSetupTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.bin = self.home / "bin"
        self.bin.mkdir()
        self.portal = self.home / "termfilechooser.portal"
        self.installed = self.home / "installed"
        self.log = self.home / "commands"
        self.env = dict(os.environ, HOME=str(self.home),
                        XDG_CONFIG_HOME=str(self.home / ".config"),
                        PATH=str(self.bin) + os.pathsep + os.defpath,
                        TEST_HOME=str(self.home))
        # Redirect only the system-file check; no real packages or services touched.
        script = (ROOT / "_postinstall/yazi_file_picker.sh").read_text()
        self.script = self.home / "_postinstall/yazi_file_picker.sh"
        self.script.parent.mkdir()
        self.script.write_text(script.replace(
            "/usr/share/xdg-desktop-portal/portals/termfilechooser.portal", str(self.portal)))
        for directory in ("xdg-desktop-portal", "xdg-desktop-portal-termfilechooser"):
            (self.home / directory).symlink_to(ROOT / directory)
        self.stub("pacman", 'test "$1" = -Q && test "$2" = ' + PACKAGE + '\n'
                  'test -f "$TEST_HOME/installed"\n')
        self.stub("yay", 'printf "yay %s\\n" "$*" >> "$TEST_HOME/commands"\n'
                  'touch "$TEST_HOME/installed" "$TEST_HOME/termfilechooser.portal"\n')
        self.stub("systemctl", 'printf "systemctl %s\\n" "$*" >> "$TEST_HOME/commands"\n')

    def stub(self, name, content):
        path = self.bin / name
        path.write_text("#!/bin/sh\nset -eu\n" + content)
        path.chmod(0o755)

    def run_setup(self):
        return subprocess.run(["/bin/sh", str(self.script)], env=self.env,
                              capture_output=True, text=True, timeout=10)

    def test_installed_package_skips_yay_on_repeated_setup(self):
        self.installed.touch()
        self.portal.touch()
        for _ in range(2):
            result = self.run_setup()
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("yay", self.log.read_text())
        target = self.home / ".config/xdg-desktop-portal/niri-portals.conf"
        self.assertTrue(target.is_symlink())
        self.assertFalse(list(target.parent.glob("*.~*~")))

    def test_missing_package_installs_once_without_search(self):
        for _ in range(2):
            result = self.run_setup()
            self.assertEqual(result.returncode, 0, result.stderr)
        installs = [line for line in self.log.read_text().splitlines() if line.startswith("yay ")]
        self.assertEqual(installs, [
            f"yay -S --needed --noconfirm --answerdiff=None --answeredit=None {PACKAGE}"])

    def test_failed_install_stops_before_linking_or_restart(self):
        self.stub("yay", "exit 42\n")
        result = self.run_setup()
        self.assertEqual(result.returncode, 42)
        self.assertFalse((self.home / ".config").exists())
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
