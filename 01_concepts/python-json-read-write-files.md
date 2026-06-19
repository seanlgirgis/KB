---
title: Python JSON — Read and Write JSON Files
tags:
  - python
  - json
  - stdlib
  - io
  - serialization
topics:
  - software-engineering
  - python-tooling
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[software-engineering-moc]]"
source:
---

# Python JSON — Read and Write JSON Files

The `json` module serializes Python objects (`dict`, `list`, `str`, `int`, `float`, `bool`, `None`) to **JSON text** and back. Use it for small config files, ledgers, API payloads, and tool output on disk. Files should be opened with **`encoding="utf-8"`** so strings round-trip correctly across platforms.

## Core idea

| Function | Direction | Target |
|----------|-----------|--------|
| `json.dump(obj, file)` | Python → JSON | write to open file handle |
| `json.dumps(obj)` | Python → JSON | return `str` |
| `json.load(file)` | JSON → Python | read from open file handle |
| `json.loads(s)` | JSON → Python | parse `str` |

**`dict` in memory ↔ `.json` on disk** is the usual pattern: load at startup, mutate in memory, dump when persisting.

## Write a JSON file (safe pattern)

Ensure the parent directory exists, write indented JSON for human diffing, end with a newline (POSIX-friendly, cleaner Git diffs).

```python
import json
from pathlib import Path


def save_json(path: Path, data: dict, *, indent: int = 2) -> None:
    """Write a dict to a UTF-8 JSON file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=indent)
        fh.write("\n")


def load_json(path: Path) -> dict:
    """Load a JSON file; return empty default if missing."""
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)
```

**Why each line matters:**

- **`mkdir(parents=True, exist_ok=True)`** — first save does not fail on missing folders.
- **`encoding="utf-8"`** — explicit on read and write; avoids Windows default surprises.
- **`indent=2`** — readable file; omit for minified machine-only JSON.
- **`fh.write("\n")`** — trailing newline; optional but common in repos and linters.

## Read-modify-write workflow

```python
from pathlib import Path
import json

config_path = Path("data/settings.json")

config = load_json(config_path)
config.setdefault("version", 1)
config["last_run"] = "2026-06-18"

save_json(config_path, config)
```

Use a **default empty structure** when the file is missing instead of crashing — common for first-run ledgers.

## Strings without files

```python
import json

payload = {"query": "rag", "k": 5}
text = json.dumps(payload)           # str for HTTP body
restored = json.loads(text)          # dict again
```

For HTTP, set `Content-Type: application/json` on the request.

## When to use

- Small structured state on disk (manifests, corpus lists, tool config)
- Interchange with APIs and CLI tools that speak JSON
- Auditable text format you can open in an editor

## When not to use

- **Large or streaming data** — consider JSONL (one object per line) or a database
- **Binary blobs** — JSON is text; embed base64 or use another format
- **Non-JSON types** — `datetime`, `Path`, custom classes need a default handler or manual conversion
- **High-concurrency writers** — use locking or a DB; last-write-wins on a single file can race

## Usage notes

- **JSON types only** — keys in objects must be strings; values limited to JSON types.
- **`ensure_ascii=False`** — `json.dump(..., ensure_ascii=False)` keeps Unicode literals readable in the file.
- **Pretty vs compact** — `indent=2` for humans; `separators=(",", ":")` for smallest size.
- **Atomic writes** — for critical files, write to `path.tmp` then `replace()` to avoid half-written JSON on crash.
- **Ledger files** — small JSON manifests pair with vector stores; see [[rag-vector-store-and-ingest-manifest]] for what to store in the dict (not in Chroma).

### Optional atomic save

```python
def save_json_atomic(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
        fh.write("\n")
    tmp.replace(path)
```

## See also

- [[rag-vector-store-and-ingest-manifest]] — ingest ledger JSON alongside vector data
- [[python-tempfile-temporary-storage]] — temp files before promoting to final JSON path
- [[software-engineering-moc]]