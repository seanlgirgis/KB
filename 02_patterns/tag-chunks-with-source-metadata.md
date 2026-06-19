---
title: Tag Chunks with Source Metadata
tags:
  - pattern
  - rag
  - metadata
  - langchain
  - ingestion
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[langchain-documents-and-loaders]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[normalize-source-url-or-local-path]]"
  - "[[rag-ingest-pipeline-spine]]"
source:
---

# Tag Chunks with Source Metadata

Every chunk stored in a shared vector database should carry a **stable source key** in metadata — e.g. `ingest_source_id` = canonical URL or absolute path. That lets you **delete all chunks from one document** before re-ingest, filter retrieval by source, and show citations without guessing which PDF a hit came from.

**Layman analogy:** every index card gets a **colored dot** for which book it came from. When you replace an edition, you pull all cards with that dot before filing new ones.

## Problem

- One Chroma collection holds many PDFs.
- Re-ingest or content change must **replace** old vectors, not duplicate.
- Vector DBs support `delete(where={metadata_key: value})` only if you stored that key at ingest.

## Approach

After split, loop chunks and set one canonical field:

```python
METADATA_SOURCE_KEY = "ingest_source_id"


def tag_chunks(chunks: list, source_id: str) -> list:
    for chunk in chunks:
        chunk.metadata[METADATA_SOURCE_KEY] = source_id
    return chunks


def load_split_and_tag(loader_path: str, source_id: str) -> list:
    pages = load_pages(loader_path)
    chunks = splitter.split_documents(pages)
    return tag_chunks(chunks, source_id)
```

`source_id` = output of [[normalize-source-url-or-local-path]] — same string as manifest row key.

## Optional extra metadata

| Field | Use |
|-------|-----|
| `title` | Human label in UI |
| `page` | Citation “page 12” |
| `ingested_at` | Audit (usually manifest is enough) |

Keep keys **consistent** across ingest and delete filters.

## Usage notes

- Tag **after** split so every chunk inherits the source.
- Use **one key name** project-wide; changing it breaks delete filters on old data.
- Do not use temp file path as `source_id` — use normalized URL or absolute user path.

## See also

- [[chroma-persist-append-and-reingest]] — delete by metadata before re-add
- [[ingest-manifest-schema-and-fields]] — manifest `source_id` aligns with chunk metadata
- [[rag-ingest-pipeline-spine]]