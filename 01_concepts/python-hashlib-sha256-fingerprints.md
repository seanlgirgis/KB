---
title: Python hashlib and SHA-256 Fingerprints
tags:
  - python
  - hashlib
  - security
  - sha256
topics:
  - software-engineering
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[password-hashing-one-way-storage]]"
  - "[[software-engineering-moc]]"
  - "[[rag-moc]]"
  - "[[python-urllib-urls-and-fetching]]"
source:
---

# Python hashlib and SHA-256 Fingerprints

`hashlib` is Python’s standard library for **cryptographic hash functions** — one-way transforms that turn arbitrary data into a fixed-length fingerprint. The same input always yields the same hash; you cannot recover the original from the hash. In kb and RAG pipelines, SHA-256 fingerprints most often mean **“has this file’s content changed since we last ingested it?”**

## Core idea

A hash function maps input of any size to a short, deterministic string. Use it when you need to **compare** or **identify** data without storing or transmitting the full payload.

- **Same bytes → same hash** (reproducible)
- **Tiny change → completely different hash** (avalanche effect)
- **One-way** — not encryption; do not treat the hash as secret by itself

## When to use

- **Content deduplication** — skip re-processing unchanged files (see [[rag-vector-store-and-ingest-manifest]])
- **Integrity checks** — verify downloads or backups were not corrupted
- **Stable IDs** — derive a key from file bytes when paths can alias the same content
- **Password storage** — use [[password-hashing-one-way-storage]] (salt + PBKDF2/bcrypt/Argon2), not bare SHA-256

## When not to use

- **Security through hashing alone** — MD5 and unsalted SHA-256 are wrong for passwords
- **Exact duplicate detection of large objects in memory** — hash still requires reading the bytes once
- **Reversible lookup** — if you need the original data back, store the data (or encrypt), do not hash

## Example

```python
import hashlib

# Hash a string (UTF-8 bytes)
text = "hello world"
digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
print(digest)
# b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9


# Hash a file on disk
def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for block in iter(lambda: fh.read(65536), b""):
            h.update(block)
    return h.hexdigest()


# Hash raw bytes (common in ingest pipelines)
def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()
```

## Algorithm choice

| Function | Notes |
|----------|--------|
| `hashlib.md5()` | Fast; **broken** for security — avoid for new integrity or auth work |
| `hashlib.sha256()` | **Default choice** — integrity, dedupe, content fingerprints |
| `hashlib.sha512()` | Stronger, longer digest; slower — use when policy requires it |

**Rule of thumb:** use `hashlib.sha256()` unless a spec or library forces another algorithm.

## Usage notes

- **Always hash bytes** — `str.encode("utf-8")` for text; `"rb"` when reading files.
- **`.hexdigest()`** — 64-character hex string; easy for JSON manifests and logs.
- **Chunked file reads** — `update()` in a loop avoids loading huge files into memory.
- **RAG ingest** — store `content_hash` in the manifest; compare before re-embedding.
- **Passwords** — see [[password-hashing-one-way-storage]]; do not reuse file-fingerprint patterns for login secrets.

## See also

- [[password-hashing-one-way-storage]] — why servers cannot store or email plaintext passwords
- [[rag-vector-store-and-ingest-manifest]] — manifest `content_hash` and skip logic
- [[software-engineering-moc]]
- [[rag-moc]]