---
title: Normalize Source — URL or Local Path
tags:
  - pattern
  - python
  - pathlib
  - urllib
  - ingestion
topics:
  - software-engineering
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[python-urllib-urls-and-fetching]]"
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[python-hashlib-sha256-fingerprints]]"
  - "[[software-engineering-moc]]"
  - "[[rag-moc]]"
source:
---

# Normalize Source — URL or Local Path

Ingest and data-loading scripts often accept **either** a web URL or a local file path from the user. `normalize_source()` returns a **canonical string** for each case: stripped URL text for http/https, or an absolute resolved filesystem path for everything else. Downstream code (manifest `source_id`, dedupe hashes, loaders) then branches on `is_url()` without guessing whether `~/data.pdf` and `./data.pdf` are the same file.

## Problem

- Users pass relative paths, `~` home shorthand, or URLs with extra whitespace.
- Relative paths depend on **current working directory** — the same string can mean different files in different runs.
- URLs must **not** go through `Path.resolve()` — that would corrupt or mis-handle them.
- Manifest dedupe needs a **stable key** per source; inconsistent path spelling creates duplicate ingests.

## Approach

1. If `is_url(source)` → return `source.strip()` only.
2. Else → `str(Path(source).expanduser().resolve())` for a canonical absolute local path.

Pair with `is_url()` from [[python-urllib-urls-and-fetching]] before fetch vs file read.

## Example

```python
from pathlib import Path
from urllib.parse import urlparse


def is_url(source: str) -> bool:
    if not isinstance(source, str):
        return False
    parsed = urlparse(source)
    return parsed.scheme in ("http", "https") and bool(parsed.netloc)


def normalize_source(source: str) -> str:
    """Canonical URL string or absolute local path."""
    if is_url(source):
        return source.strip()
    return str(Path(source).expanduser().resolve())


def load_source(source: str) -> str:
    normalized = normalize_source(source)
    if is_url(normalized):
        # download via urlopen — see python-urllib-urls-and-fetching
        ...
    return Path(normalized).read_text(encoding="utf-8")
```

### Path behavior

| Step | Local path effect |
|------|-------------------|
| `Path(source)` | OS-native path object |
| `.expanduser()` | `~/docs/file.pdf` → home directory expanded |
| `.resolve()` | relative → absolute; folds `..` and symlinks |

### Examples

| Input | Output (illustrative) | Notes |
|-------|----------------------|-------|
| `https://example.com/data.csv` | `https://example.com/data.csv` | URL unchanged except strip |
| `  https://google.com  ` | `https://google.com` | whitespace trimmed |
| `./data.csv` | `/home/user/project/data.csv` | cwd-dependent before resolve |
| `~/documents/file.txt` | `/home/user/documents/file.txt` | tilde expanded |
| `/app/data/../config.json` | `/app/config.json` | `resolve()` cleans |

On Windows, `resolve()` yields drive-letter absolutes (e.g. `D:\Workarea\file.pdf`).

## Tradeoffs

- **URLs** — only whitespace normalization; no lowercasing host or trailing-slash policy unless you add it explicitly.
- **Local paths** — `resolve()` requires the path to exist on some OS versions; broken symlinks can raise.
- **Not validation** — `is_url` checks shape, not reachability; paths are not checked for existence here.
- **Manifest key** — use `normalize_source()` output as `source_id`; hash **content bytes**, not the path string alone (see [[rag-vector-store-and-ingest-manifest]]).

## Usage notes

- Call **once at the ingest boundary** — every later step uses the normalized string.
- **Same file, different spellings** — `./paper.pdf` and resolved absolute path should map to one manifest entry after normalize.
- **URL sources** — keep the normalized URL as `source_id`; hash downloaded bytes with [[python-hashlib-sha256-fingerprints]].
- **Do not** `resolve()` URLs — branch on `is_url` first.

## See also

- [[python-urllib-urls-and-fetching]] — `is_url`, `urlopen`, URL fetch
- [[rag-vector-store-and-ingest-manifest]] — `source_id` in manifest ledger
- [[python-tempfile-temporary-storage]] — stage URL downloads to temp paths
- [[software-engineering-moc]]
- [[rag-moc]]