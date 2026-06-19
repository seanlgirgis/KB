---
title: Incremental RAG Ingest Build Order
tags:
  - learning
  - rag
  - ingestion
  - capstone
topics:
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-ingest-pipeline-spine]]"
  - "[[ingest-cli-parser-and-handlers]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[rag-moc]]"
source: Learning lab — bite-by-bite ingest script construction
---

# Incremental RAG Ingest Build Order

Building a full ingest script in **small verified bites** beats writing 300 lines before the first run. Each bite adds one layer you can test in isolation — paths, then I/O helpers, then ledger, then chunking, then vectors, then CLI.

**Layman analogy:** assemble furniture by **locking one shelf at a time** and checking it is level before adding the next — not dumping all screws on the floor at once.

## Suggested bite order

| Bite | What you add | How to verify |
|------|----------------|---------------|
| 1 | Imports, paths, constants (`CHROMA_DIR`, `MANIFEST_PATH`, chunk sizes) | Print paths; dirs exist |
| 2 | `is_url`, `normalize_source`, `read_source_bytes`, `sha256_bytes` | Probe: hash + byte count for one PDF |
| 3 | `load_manifest`, `save_manifest`, skip logic in `ingest_source` | Run twice; second run skips |
| 4 | Loader + splitter + `tag_chunks` | Print chunk count only (no embed yet) |
| 5 | Chroma `from_documents` / `add_documents`, delete on re-ingest | `--list` + query script finds chunks |
| 6 | `argparse`: source, `--list`, `--corpus`, `--force` | CLI modes independent |

## Why this order

- **Cheap before expensive** — hash/manifest skip before API embed calls.
- **Probe before persist** — bite 2-style debug avoids debugging Chroma and PDFs simultaneously.
- **CLI last** — orchestration wraps a working `ingest_source`.

## Interview / recall spine

Say out loud: **resolve → hash → manifest decision → load/split/tag → embed → persist → manifest write**.

Maps to [[rag-ingest-pipeline-spine]] for the generic version.

## What to peek at only after trying

Reference implementations in course repos are for **diffing**, not copy-paste first. Get your bite working, then compare edge cases (delete failures, empty PDF pages).

## See also

- [[rag-ingest-pipeline-spine]]
- [[read-source-bytes-and-loader-path]]
- [[corpus-batch-ingest]]
- [[rag-moc]]