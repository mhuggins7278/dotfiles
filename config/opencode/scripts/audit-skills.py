#!/usr/bin/env python3
"""Check the local OpenCode skill inventory without third-party dependencies."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1] / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
LINK_RE = re.compile(r"\]\(([^)#]+)(?:#[^)]+)?\)")


def frontmatter(path: Path) -> tuple[str | None, str | None]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return None, None
    try:
        end = lines.index("---", 1)
    except ValueError:
        return None, None

    block = lines[1:end]
    name = next(
        (
            line.split(":", 1)[1].strip().strip("\"'")
            for line in block
            if line.startswith("name:")
        ),
        None,
    )
    description_index = next(
        (index for index, line in enumerate(block) if line.startswith("description:")),
        None,
    )
    if description_index is None:
        return name, None

    description = block[description_index].split(":", 1)[1].strip()
    if description in {">", "|", ">-", "|-"}:
        description = " ".join(
            line.strip() for line in block[description_index + 1 :] if line.strip()
        )
    return name, description.strip("\"'") or None


def main() -> int:
    skills = sorted(ROOT.glob("*/SKILL.md"))
    errors: list[str] = []
    warnings: list[str] = []
    names: dict[str, Path] = {}

    if not skills:
        print(f"error: no skills found under {ROOT}")
        return 1

    for path in skills:
        folder = path.parent.name
        name, description = frontmatter(path)
        if name is None or description is None:
            errors.append(f"{path}: missing valid name or description")
            continue
        if name != folder:
            errors.append(f"{path}: name {name!r} does not match folder {folder!r}")
        if not NAME_RE.fullmatch(name):
            errors.append(f"{path}: invalid skill name {name!r}")
        if name in names:
            errors.append(f"duplicate skill name {name!r}: {names[name]} and {path}")
        names[name] = path

        for target in LINK_RE.findall(path.read_text(encoding="utf-8")):
            if target.startswith(("http://", "https://", "#")):
                continue
            if not (path.parent / target).resolve().exists():
                errors.append(f"{path}: broken local reference {target!r}")

    for directory in sorted(ROOT.iterdir()):
        if not directory.is_dir() or (directory / "SKILL.md").exists():
            continue
        if directory.name.endswith("-workspace"):
            warnings.append(f"workspace directory is not a skill: {directory}")
        else:
            warnings.append(f"directory has no SKILL.md: {directory}")

    total_bytes = sum(path.stat().st_size for path in skills)
    total_lines = sum(
        len(path.read_text(encoding="utf-8").splitlines()) for path in skills
    )
    print(f"skills: {len(skills)}")
    print(f"primary SKILL.md surface: {total_lines} lines, {total_bytes} bytes")
    for path in skills:
        lines = len(path.read_text(encoding="utf-8").splitlines())
        print(f"  {path.parent.name}: {lines} lines")
    for warning in warnings:
        print(f"warning: {warning}")
    for error in errors:
        print(f"error: {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
