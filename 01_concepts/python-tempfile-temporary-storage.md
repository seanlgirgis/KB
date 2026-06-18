---
title: Python tempfile — Temporary Files and Directories
tags:
  - python
  - tempfile
  - stdlib
  - io
topics:
  - software-engineering
  - python-tooling
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[software-engineering-moc]]"
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[python-urllib-urls-and-fetching]]"
source:
---

# Python tempfile — Temporary Files and Directories

`tempfile` is a built-in standard-library module for creating **short-lived files and directories** with unique names, sensible permissions, and (for high-level helpers) automatic cleanup. Use it whenever a script must stage data on disk — downloaded PDFs, upload buffers, test fixtures, build artifacts — without polluting the project tree or colliding with existing filenames.

## Core idea

Temporary storage should be **unique**, **isolated**, and **cleaned up**. `tempfile` picks the OS temp location (`/tmp` on Unix, `%TEMP%` on Windows via `gettempdir()`), generates unpredictable names, and provides context managers that delete resources when done — even if your code raises an exception.

## When to use

- Processing uploads or remote downloads before ingest (e.g. load a PDF from URL into a temp path for a loader)
- Caching intermediate pipeline output for one run
- Unit tests that need real files or directories
- Building archives or installers from staged files
- Any script that must not leave debris in the working directory

## When not to use

- **Long-lived caches** — use a dedicated cache dir you manage explicitly
- **Secrets** — temp dirs may be world-readable on some systems; treat contents as sensitive only with correct permissions and short lifetime
- **Low-level `mkstemp` / `mkdtemp`** without a cleanup plan — you own deletion

## Common APIs

| API | Purpose | Auto-deleted? |
|-----|---------|---------------|
| `TemporaryFile()` | Anonymous temp file (often no stable path) | Yes, on close |
| `NamedTemporaryFile()` | Named temp file (path available) | Yes, on close (default `delete=True`) |
| `SpooledTemporaryFile()` | Memory until size threshold, then disk | Yes |
| `TemporaryDirectory()` | Temp folder for multiple files | Yes, on context exit |
| `mkstemp()` | Returns `(fd, path)` — low-level | **No** — you delete |
| `mkdtemp()` | Returns directory path — low-level | **No** — you delete |
| `gettempdir()` | System default temp directory | — |

## Example

```python
import os
import tempfile

# Anonymous temp file — good default
with tempfile.TemporaryFile(mode="w+t", encoding="utf-8") as f:
    f.write("Hello, temporary world!")
    f.seek(0)
    print(f.read())
# deleted after with-block


# Named temp file — when a library needs a path
with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=True) as f:
    f.write("Some data")
    f.flush()
    path = f.name
    # pass path to another tool before block ends
# deleted after with-block


# Temp directory — multiple files, one cleanup
with tempfile.TemporaryDirectory(prefix="ingest_") as tmpdir:
    staging = os.path.join(tmpdir, "download.pdf")
    # write or download into staging, process, discard
# directory tree removed
```

## Usage notes

- **Always prefer `with`** — guarantees cleanup on exceptions.
- **`suffix` / `prefix`** — clarify type (`suffix=".pdf"`) or namespace (`prefix="capstone_"`).
- **`dir=`** — force temp under a specific parent (e.g. fast local disk) instead of system default.
- **`NamedTemporaryFile(delete=False)`** — rare cases where another process must read after close; you must `os.unlink` yourself.
- **`delete_on_close`** (Python 3.12+) — finer control on Windows when another handle still needs the path.
- **RAG ingest** — URL-fetched PDFs often land in a temp file so `PyPDFLoader(path)` can run; pair with [[rag-vector-store-and-ingest-manifest]] logic on the **source bytes**, not the temp path, for stable `source_id`.

## See also

- [[python-urllib-urls-and-fetching]] — `urlopen` then write bytes into a temp path
- [[software-engineering-moc]]
- [[rag-vector-store-and-ingest-manifest]] — ingest staging; hash source content, not ephemeral temp names