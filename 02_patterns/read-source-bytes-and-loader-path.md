---
title: Read Source Bytes and Loader Path
tags:
  - pattern
  - python
  - ingestion
  - io
topics:
  - indexing
  - software-engineering
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[normalize-source-url-or-local-path]]"
  - "[[python-urllib-urls-and-fetching]]"
  - "[[python-tempfile-temporary-storage]]"
  - "[[python-hashlib-sha256-fingerprints]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[rag-ingest-pipeline-spine]]"
source:
---

# Read Source Bytes and Loader Path

Many loaders (PDF, DOCX) want a **filesystem path**, but dedupe wants **raw bytes** to hash. When ingest handles **PDF and web** in one pipeline, `read_source_bytes(source) -> (bytes, loader_path | None, kind)` returns bytes for fingerprinting, an optional path for file-based loaders, and **`"pdf"`** or **`"web"`** so downstream picks `PyPDFLoader` vs `WebBaseLoader`.

**Layman analogy:** you need the **weight** of a package (hash the bytes), a **counter slot** where the clerk opens it (PDF path), and a **label** (pdf vs web) so the right reader is used.

## Problem

- Hash must reflect **content**, not spelling of `./paper.pdf` vs absolute path.
- `PyPDFLoader` and friends typically need `"/path/to/file.pdf"`, not raw bytes in memory.
- URL downloads are bytes in RAM — you must stage to disk (usually temp).

## Approach

1. `source_id = normalize_source(source)`
2. **`is_pdf_source(source)`** — local `.pdf` suffix or URL path ending in `.pdf`
3. **PDF branch:** `read_pdf_bytes` → `(bytes, loader_path)` — URL downloads to temp `.pdf`; local uses real path
4. **Web branch:** `read_web_bytes(url)` → raw HTML bytes; `loader_path = None`; `WebBaseLoader(source_id)` loads at split time
5. Return `(hash_bytes, loader_path, kind)` where `kind` is `"pdf"` or `"web"`

Hash the **bytes** from step 3/4, not the path string. Web hash uses fetched page bytes without running the full HTML parser.

## Example

```python
def is_pdf_source(source: str) -> bool:
    source_id = normalize_source(source)
    if is_url(source_id):
        return urlparse(source_id).path.lower().endswith(".pdf")
    return Path(source_id).suffix.lower() == ".pdf"


def read_pdf_bytes(source: str) -> tuple[bytes, str]:
    source_id = normalize_source(source)
    if is_url(source_id):
        with urlopen(source_id, timeout=120) as response:
            data = response.read()
        tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".pdf")
        tmp.write(data)
        tmp.close()
        return data, tmp.name
    path = Path(source_id)
    return path.read_bytes(), str(path)


def read_web_bytes(source: str) -> bytes:
    source_id = normalize_source(source)
    with urlopen(source_id, timeout=120) as response:
        return response.read()


def read_source_bytes(source: str) -> tuple[bytes, str | None, str]:
    if is_pdf_source(source):
        raw, loader_path = read_pdf_bytes(source)
        return raw, loader_path, "pdf"
    raw = read_web_bytes(source)
    return raw, None, "web"
```

## Usage notes

- **Same bytes, two paths** — re-downloading a URL should match prior hash if content unchanged.
- **Temp cleanup** — delete temp files after ingest or register shutdown cleanup; see [[python-tempfile-temporary-storage]].
- **Suffix** — `.pdf` on temp files helps PyPDF; non-PDF URLs skip temp staging.
- **Manifest key** — still `normalize_source(source)` (URL or absolute path), not temp path.
- **`kind` in manifest** — record `"pdf"` or `"web"` per source; see [[ingest-manifest-schema-and-fields]].

## See also

- [[incremental-rag-web-ingest]]
- [[ingest-manifest-schema-and-fields]]
- [[python-urllib-urls-and-fetching]]
- [[python-hashlib-sha256-fingerprints]]
- [[langchain-documents-and-loaders]]
- [[rag-ingest-pipeline-spine]]