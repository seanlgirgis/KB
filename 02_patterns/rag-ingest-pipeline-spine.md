---
title: RAG Ingest Pipeline Spine
tags:
  - pattern
  - rag
  - ingestion
  - pipeline
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[normalize-source-url-or-local-path]]"
  - "[[read-source-bytes-and-loader-path]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[ingest-manifest-schema-and-fields]]"
  - "[[rag-moc]]"
source:
---

# RAG Ingest Pipeline Spine

A complete **ingest run** turns one source (file or URL) into searchable vectors on disk, with a manifest row so you never pay twice for unchanged content. Think of it as an assembly line: each station does one job, in order, and hands a clear result to the next.

**Layman analogy:** receive a book → photograph every page for filing (chunks) → file cards in a search cabinet (vector store) → log “we filed this edition” in a desk ledger (manifest).

## Pipeline stages (in order)

```text
1. RESOLVE   normalize_source(source) → canonical source_id
2. READ      raw bytes + path loaders can open
3. FINGERPRINT  sha256(raw bytes) → content_hash
4. DECIDE    manifest says skip, update, or first-time ingest?
5. LOAD      document loader → pages/sections
6. SPLIT     text splitter → chunks
7. TAG       stamp metadata (source id) on every chunk
8. EMBED     embedding model → vectors
9. PERSIST   write/update vector store (delete old rows if re-ingest)
10. RECORD   update manifest row (hash, chunk_count, ingested_at)
```

Stages 1–4 are cheap. Stages 5–9 cost network/API time — that is why the manifest exists.

## Ingest outcomes (state machine)

One orchestrator function (e.g. `ingest_source`) should return a **status string** so CLI and batch jobs can count results.

| Status | Meaning | Typical trigger |
|--------|---------|-----------------|
| `skipped` | Manifest hash matches; no embed work | Same file/URL, same bytes, no `--force` |
| `ingested` | First time this `source_id` | New manifest row |
| `updated` | Known `source_id`, new hash or `--force` | File changed or forced re-embed |

**Decision logic (simplified):**

```python
prior = manifest["sources"].get(source_id)
if prior and prior["content_hash"] == content_hash and not force:
    return "skipped"

action = "updated" if prior else "ingested"
# ... load, split, embed, persist, save manifest ...
return action
```

**`--force`:** skip the hash check for *whether to run*; still delete old vectors for that source before adding new ones (see [[chroma-persist-append-and-reingest]]).

## Example orchestrator sketch

Generic names — wire your loaders and stores.

```python
def ingest_source(source: str, *, force: bool = False) -> str:
    source_id = normalize_source(source)
    raw, loader_path = read_source_bytes(source)
    content_hash = sha256_bytes(raw)

    manifest = load_manifest()
    prior = manifest.get("sources", {}).get(source_id)

    if prior and prior.get("content_hash") == content_hash and not force:
        return "skipped"

    action = "updated" if prior else "ingested"
    chunks = load_split_and_tag(loader_path, source_id)
    persist_chunks(chunks, source_id=source_id, prior=prior, force=force)

    manifest.setdefault("sources", {})[source_id] = {
        "content_hash": content_hash,
        "chunk_count": len(chunks),
        "ingested_at": utc_now_iso(),
    }
    save_manifest(manifest)
    return action
```

## When to use this shape

- Any script that ingests PDFs, markdown exports, or HTML into Chroma-like stores
- When you need `--list` (manifest only) separate from heavy embed path
- When batch corpus runs need per-item status counts

## Tradeoffs

- **Monolith vs modules** — one `ingest_source` is fine early; split into functions per stage when testing.
- **Skip before load** — always hash **bytes** before PDF parse/split if possible (fast dedupe).
- **Failure mid-pipeline** — manifest should not update if embed fails; use try/except in batch loops.

## See also

- [[read-source-bytes-and-loader-path]] — stage 2
- [[rag-text-chunking-splitters]] — stage 6
- [[tag-chunks-with-source-metadata]] — stage 7
- [[chroma-persist-append-and-reingest]] — stage 9
- [[ingest-manifest-schema-and-fields]] — stage 10
- [[corpus-batch-ingest]] — run spine in a loop
- [[ingest-cli-parser-and-handlers]] — CLI around the spine