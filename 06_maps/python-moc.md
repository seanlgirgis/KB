---
title: Python MOC
tags:
  - moc
  - python
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[kb-home]]"
  - "[[software-engineering-moc]]"
  - "[[rag-moc]]"
---

# Python — Map of Content

Stdlib and Python craft notes used across RAG and general engineering. **Navigate here or Obsidian search** — not by scrolling `01_concepts/`.

## Stdlib & I/O

- [[python-argparse-cli]] — CLI flags and dispatch
- [[python-json-read-write-files]] — JSON ledgers and config
- [[python-urllib-urls-and-fetching]] — URLs, `urlopen`, ingest fetch
- [[python-tempfile-temporary-storage]] — staged PDFs and temp paths
- [[python-hashlib-sha256-fingerprints]] — `content_hash` dedupe
- [[python-project-root-for-imports]] — `sys.path` for nested scripts

## Security & data

- [[password-hashing-one-way-storage]] — salted hashes (not RAG-specific)

## Patterns that lean on Python (cross-linked)

- [[normalize-source-url-or-local-path]]
- [[ingest-cli-parser-and-handlers]]
- [[read-source-bytes-and-loader-path]]

## See also

- [[rag-moc]] — many patterns above serve ingest/chat
- [[software-engineering-moc]]
- [[kb-home]]