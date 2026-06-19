---
title: Python argparse — Command-Line Interfaces
tags:
  - python
  - argparse
  - stdlib
  - cli
topics:
  - software-engineering
  - python-tooling
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[ingest-cli-parser-and-handlers]]"
  - "[[software-engineering-moc]]"
source:
---

# Python argparse — Command-Line Interfaces

`argparse` is Python’s standard-library module for parsing command-line arguments into a structured namespace. You define flags, positional args, help text, and types once; `parse_args()` handles `--help`, errors, and conversions. Use it for ingest scripts, vault tools, and any `python tool.py --flag value` workflow instead of hand-parsing `sys.argv`.

## Core idea

| Piece | Role |
|-------|------|
| `ArgumentParser` | Container for all arguments and global options |
| `add_argument()` | One flag or positional per call |
| `parse_args()` | Reads `sys.argv`; returns `Namespace` (e.g. `args.list`, `args.force`) |
| `main()` dispatch | `if args.list: cmd_list()` — keep parsing separate from work |

Build the parser in a **`build_parser()`** function so tests can import it without running the script.

## Common argument shapes

```python
import argparse


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Ingest sources into a vector store.",
    )

    # Optional positional — 0 or 1 value
    parser.add_argument(
        "source",
        nargs="?",
        default=None,
        help="File path or URL to ingest",
    )

    # Boolean flag — no value; True when present
    parser.add_argument(
        "--list",
        action="store_true",
        help="Print manifest entries and exit",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-process even if content hash unchanged",
    )

    # Optional value flag
    parser.add_argument(
        "--corpus",
        metavar="FILE",
        help="JSON file listing batch sources",
    )

    return parser


def main() -> None:
    args = build_parser().parse_args()
    if args.list:
        cmd_list()
        return
    if args.corpus:
        cmd_corpus(args.corpus)
        return
    if args.source is None:
        build_parser().print_help()
        return
    ingest_source(args.source, force=args.force)


if __name__ == "__main__":
    main()
```

## Argument patterns cheat sheet

| Pattern | `add_argument` | Result |
|---------|----------------|--------|
| Optional positional | `nargs="?"`, `default=None` | Zero or one `source` |
| Required positional | no `nargs` | Exactly one value |
| Boolean flag | `action="store_true"` | `args.force` is `False` or `True` |
| Optional named flag | `--out`, `default="out.json"` | `args.out` string |
| Choices | `choices=["json", "csv"]` | Validates allowed values |
| Count / verbose | `action="count"`, `default=0` | `-v`, `-vv` increments |

## When to use

- Scripts users run from the shell with `--help` expectations
- Multiple modes (ingest one file, `--list` manifest, `--probe` debug)
- Sharing one entrypoint across sub-behaviors

## When not to use

- Single fixed script with no flags — `if __name__` block may suffice
- Interactive TUIs — consider `click` or `typer` for richer UX
- Library code called only from other Python modules — no CLI layer needed

## Usage notes

- **`description=`** and per-arg **`help=`** feed `--help`; write them for future you.
- **`metavar=`** shortens help display for opaque names.
- **`type=`** — coerce strings (`int`, `Path` via lambda) before handlers run.
- **Exit on error** — argparse prints usage and exits on unknown flags; no try/except required for typos.
- **Handler functions** — name `cmd_*` or `run_*`; one job each (see [[ingest-cli-parser-and-handlers]]).

## See also

- [[ingest-cli-parser-and-handlers]] — `cmd_list`, `cmd_probe`, ingest dispatch
- [[software-engineering-moc]]