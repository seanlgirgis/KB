---
title: Software Engineering MOC
tags:
  - moc
topics:
  - software-engineering
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[python-project-root-for-imports]]"
---

# Software Engineering — Map of Content

Index for patterns, architecture, and engineering practices.

## Patterns

- [[normalize-source-url-or-local-path]] — `normalize_source()` for URL strip or absolute local path
- [[ingest-cli-parser-and-handlers]] — `cmd_list`, `cmd_probe`, `build_parser`, `main` dispatch

## Web & HTTP

- [[agentic-rag-web-service-stack]] — FastAPI/Flask/LangServe serving RAG and agents
- [[flask-http-get-and-post]] — GET vs POST, Flask routes, `request.args` / `request.form`

## Architecture

-

## Python & tooling

Full stdlib index: [[python-moc]].

- [[python-project-root-for-imports]] — find the import root, add to `sys.path`, copy-paste block
- [[python-hashlib-sha256-fingerprints]] — `hashlib.sha256()` for file and byte fingerprints
- [[password-hashing-one-way-storage]] — salted slow hashes; why sites cannot “remind” passwords
- [[python-tempfile-temporary-storage]] — temp files/dirs, context managers, ingest staging
- [[python-urllib-urls-and-fetching]] — `urlparse`, `is_url`, `urlopen`, ingest routing
- [[python-argparse-cli]] — `ArgumentParser`, flags, optional positionals
- [[python-json-read-write-files]] — `json.dump` / `load`, UTF-8, atomic save

## Testing & quality

-

## Snippets

- See `03_snippets/` — standalone blocks reused across 3+ notes (`docs/NOTE_CONVENTIONS.md`, one-sheet rule)