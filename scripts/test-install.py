#!/usr/bin/env python3
"""Exercise installer safety in a disposable HOME; no sudo or real KDE bus."""
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(args, env, cwd=ROOT):
    result = subprocess.run(args, env=env, cwd=cwd, capture_output=True, text=True)
    if result.returncode:
        raise AssertionError(f"{args}: {result.returncode}\n{result.stdout}\n{result.stderr}")
    return result.stdout


def snapshot(home):
    return {
        str(p.relative_to(home)): ("link", os.readlink(p)) if p.is_symlink()
        else ("file", hashlib.sha256(p.read_bytes()).hexdigest())
        for p in home.rglob("*")
        if (p.is_file() or p.is_symlink()) and ".local/state/" not in str(p.relative_to(home))
    }


with tempfile.TemporaryDirectory(prefix="batcomputer-test-") as tmp:
    base = Path(tmp)
    home = base / "home"
    home.mkdir()
    mocks = base / "bin"
    mocks.mkdir()
    # Package availability only is mocked: the installer must never invoke -S.
    pacman = mocks / "pacman"
    pacman.write_text('#!/bin/sh\n[ "$1" = -Q ] || exit 99\n')
    pacman.chmod(0o755)
    # Restore must inspect the disposable HOME, not the real running desktop.
    pgrep = mocks / "pgrep"
    pgrep.write_text('#!/bin/sh\nexit 1\n')
    pgrep.chmod(0o755)
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / ".config"),
               XDG_DATA_HOME=str(home / ".local/share"), XDG_STATE_HOME=str(home / ".local/state"),
               XDG_CACHE_HOME=str(home / ".cache"), XDG_CURRENT_DESKTOP="",
               DBUS_SESSION_BUS_ADDRESS="unix:path=/nonexistent-batcomputer-test",
               QT_QPA_PLATFORM="offscreen", PATH=f"{mocks}:/usr/bin:/bin")
    env.pop("BATCOMPUTER_BACKUP_DIR", None)
    fish_dir = home / ".config/fish"
    (fish_dir / "functions").mkdir(parents=True)
    original = home / "original.fish"
    original.write_text("# existing config target\n")
    (fish_dir / "config.fish").symlink_to(original)
    (fish_dir / "functions/personal.fish").write_text("# unrelated file\n")
    original_kde = home / 'original-kdeglobals'
    original_kde.write_text("[Personal]\nKeepMe=yes\n")
    (home / ".config/kdeglobals").symlink_to(original_kde)
    before = snapshot(home)
    run([str(ROOT / "install.sh"), "--dry-run"], env)
    assert snapshot(home) == before, "dry-run changed files"
    output = run([str(ROOT / "install.sh"), "--skip-packages"], env)
    first_backup = next(p for p in (home / ".local/state/batcomputer/backups").iterdir())
    installed = snapshot(home)
    assert original.read_text() == "# existing config target\n", "followed and overwrote symlink target"
    assert original_kde.read_text() == "[Personal]\nKeepMe=yes\n", "KConfig overwrote symlink target"
    assert not (fish_dir / "config.fish").is_symlink()
    assert "KeepMe=yes" in (home / ".config/kdeglobals").read_text()
    assert "ColorScheme=Batcomputer" in (home / ".config/kdeglobals").read_text()
    run([str(ROOT / "install.sh"), "--skip-packages"], env)
    assert snapshot(home) == installed, "rerun changed deployed configuration"
    run([str(ROOT / "scripts/restore.sh"), str(first_backup)], env)
    assert snapshot(home) == before, "restore did not recover original files/symlink"
    print("PASS: dry-run, deployment, symlink safety, unrelated-file preservation, rerun idempotency, rollback")
