---
title: RAG Vector Store and Ingest Manifest
tags:
  - rag
  - vector-db
  - chromadb
  - ingestion
  - embeddings
topics:
  - retrieval
  - indexing
  - chunking
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-moc]]"
source: Distilled from LangChain capstone storage note (learning/playground)
---

# RAG Vector Store and Ingest Manifest

A practical RAG pipeline uses **two different stores** with different jobs: a **persisted vector store directory** (searchable embeddings at query time) and a separate **ingest manifest** (a small ledger that records which sources were embedded and whether content changed). The vector store answers “which chunks match this question?” The manifest answers “did we already embed this exact source?” Confusing the two leads to re-embedding everything on every run or searching an empty index.

## Core idea

| Store | What it holds | Used when |
|-------|---------------|-----------|
| **Vector store dir** | Chunk embeddings + chunk metadata (text, source, tags) | **Retrieval** — every query |
| **Ingest manifest** | Per-source id, content hash, chunk count, ingest timestamp | **Ingest only** — dedupe and skip |

The vector store is **not** a substitute for ingest bookkeeping. Chroma (and similar DBs) do not ship a “skip unchanged PDF” ledger — you add a manifest (or equivalent DB table) in your ingest script.

**Human analogy:** the vector store is the **filing cabinet of index cards** (search by similarity). The manifest is the **checkout log** (“source X filed on Tuesday, hash abc, 57 cards”) so you do not re-file unchanged documents.

## Vector store directory

A **persist directory** is where the vector database writes durable state between runs. In Chroma with LangChain, `persist_directory` points at a folder that grows as you add chunks.

At query time you:

1. Load the same persist path the ingest job used.
2. Embed the user question with the **same embedding model** as ingest.
3. Retrieve top-k similar chunks and pass them to the LLM.

If the directory is missing or empty, chat/retrieval has nothing to search — regardless of what the manifest says.

### Typical on-disk layout (Chroma example)

Chroma’s folder is more than a single file:

```text
chroma_data/
  chroma.sqlite3           # collection catalog, ids, metadata
  <collection-uuid>/
    data_level0.bin        # vector index (HNSW)
    header.bin
    length.bin
    link_lists.bin
```

Treat the whole directory as one artifact — back it up, version paths in config, and point both ingest and query code at the **same path**.

## Ingest manifest

A **manifest** is a small JSON (or SQLite) file **your pipeline maintains**. Each ingested source gets a row keyed by a stable `source_id` (canonical file path, vault-relative path, or URL).

Typical fields per source:

- `content_hash` — hash of raw bytes (SHA-256) so “same path, new content” triggers re-ingest
- `chunk_count` — sanity check and logging
- `ingested_at` — audit trail
- `title` or display name — optional human label

**Ingest logic:** compute hash → if manifest entry exists and hash matches → **skip** embed; else chunk, embed, write vectors, update manifest.

**Query logic:** manifest is **not read**. Only the vector store matters.

## Ingest vs query lifecycle

```text
INGEST (once per new or changed source)
  source → read bytes → hash
       → compare manifest → skip if unchanged
       → chunk → embed → write to vector store dir
       → update manifest (source_id + hash + metadata)

QUERY (many times)
  question → embed question → search vector store dir → top chunks → LLM
  (manifest not used)
```

Both scripts must agree on **vector store path** and **embedding model**. The manifest path is ingest-only but should live alongside the vector data for operational clarity.

## Example manifest

```json
{
  "version": 1,
  "chunk_size": 500,
  "chunk_overlap": 50,
  "sources": {
    "/data/papers/langchain-overview.pdf": {
      "title": "langchain-overview.pdf",
      "content_hash": "7eb7a0e69595d0ab5c92b32ee7f7d365d8165d87f073da29c5b8c36c7fd02c01",
      "chunk_count": 57,
      "ingested_at": "2026-06-18T20:00:48.674240+00:00"
    }
  }
}
```

## Example code

Illustrative pattern — adapt paths and libraries to your project.

```python
import json
import hashlib
from pathlib import Path

CHROMA_DIR = Path("data/chroma")
MANIFEST_PATH = Path("data/ingest_manifest.json")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_manifest() -> dict:
    if not MANIFEST_PATH.exists():
        return {"version": 1, "sources": {}}
    return json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))


def save_manifest(manifest: dict) -> None:
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2), encoding="utf-8")


def should_skip_ingest(manifest: dict, source_id: str, content_hash: str) -> bool:
    prior = manifest.get("sources", {}).get(source_id)
    return prior is not None and prior.get("content_hash") == content_hash


def ingest_source(source_id: str, raw_bytes: bytes, chunks: list, embed_and_store) -> None:
    """embed_and_store(chunks) writes to CHROMA_DIR (e.g. Chroma.from_documents / add_documents)."""
    content_hash = sha256_bytes(raw_bytes)
    manifest = load_manifest()

    if should_skip_ingest(manifest, source_id, content_hash):
        return  # unchanged — do not re-embed

    CHROMA_DIR.mkdir(parents=True, exist_ok=True)
    embed_and_store(chunks)

    manifest.setdefault("sources", {})[source_id] = {
        "content_hash": content_hash,
        "chunk_count": len(chunks),
    }
    save_manifest(manifest)


def query_vector_store(question: str, embed_fn, search_fn) -> list:
    """search_fn returns top-k chunks from CHROMA_DIR only — manifest not involved."""
    query_vector = embed_fn(question)
    return search_fn(CHROMA_DIR, query_vector)
```

Chroma-specific ingest often looks like:

```python
from langchain_chroma import Chroma

# First ingest
Chroma.from_documents(chunks, embedding_model, persist_directory=str(CHROMA_DIR))

# Later append or re-open
store = Chroma(persist_directory=str(CHROMA_DIR), embedding_function=embedding_model)
store.add_documents(new_chunks)
```

## Usage notes

- **Same embedding model** for ingest and query — or re-embed everything after a model change.
- **Re-ingest on hash change** — delete or overwrite old chunks for that `source_id` in the vector store, then update the manifest row.
- **`--force` flag** — bypass manifest skip when you change chunking rules without source bytes changing.
- **kb vault future** — markdown files under version control can use the same pattern: `source_id` = vault-relative path, `content_hash` = file hash at ingest time.
- **Do not commit** large vector dirs or secrets to Git; manifest is usually small enough to commit or regenerate.

## When to use

- Any local RAG prototype that ingests files incrementally (PDFs, markdown vault export, HTML).
- When re-embedding costs money or time and sources change slowly.
- When ingest and chat are separate scripts or processes sharing one persist directory.

## See also

- [[rag-moc]]