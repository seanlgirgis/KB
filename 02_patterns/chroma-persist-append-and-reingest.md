---
title: Chroma Persist, Append, and Re-Ingest
tags:
  - pattern
  - rag
  - chromadb
  - langchain
  - ingestion
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[watsonx-truncate-input-tokens-rag-trap]]"
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[tag-chunks-with-source-metadata]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-moc]]"
source:
---

# Chroma Persist, Append, and Re-Ingest

LangChain’s **Chroma** integration can **create** a new on-disk store or **open** an existing one and append documents. Re-ingest (changed file or `--force`) must **delete old chunks for that source** before adding new ones, or searches return duplicates and stale text.

**Layman analogy:** first book fills a new filing cabinet (`from_documents`). Later books slide into the same cabinet (`add_documents`). When you replace a book, pull out **all its old cards** first (`delete` by source tag), then file the new set.

## Open or create

```python
from langchain_community.vectorstores import Chroma


def chroma_has_data(persist_dir) -> bool:
    return persist_dir.exists() and any(persist_dir.iterdir())


def open_vector_store(persist_dir, embedding_model):
    if not chroma_has_data(persist_dir):
        return None
    return Chroma(
        persist_directory=str(persist_dir),
        embedding_function=embedding_model,
    )
```

## First source vs later sources

| Situation | API |
|-----------|-----|
| Empty persist dir | `Chroma.from_documents(chunks, embed_model, persist_directory=...)` |
| Store already has data | `store = open_vector_store(...)` then `store.add_documents(chunks)` |

```python
persist_dir.mkdir(parents=True, exist_ok=True)
embedding_model = make_embedding_model()
store = open_vector_store(persist_dir, embedding_model)

if store is None:
    Chroma.from_documents(chunks, embedding_model, persist_directory=str(persist_dir))
else:
    if prior_manifest_row or force:
        delete_source_chunks(store, source_id)
    store.add_documents(chunks)
```

## Delete before re-ingest

Requires [[tag-chunks-with-source-metadata]].

```python
def delete_source_chunks(store, source_id: str, *, metadata_key: str = "ingest_source_id") -> None:
    try:
        store._collection.delete(where={metadata_key: source_id})
    except Exception as exc:
        print(f"warning: delete failed for {source_id}: {exc}")
```

Run delete when:

- `content_hash` changed (updated ingest)
- **`--force`** even if hash unchanged — deletes by `ingest_source_id` then re-adds; **not** duplicate append

**Use `--force` when:**

- `chunk_size` / overlap / splitter rules changed
- **`EMBED_PARAMS` changed** (e.g. removed Watsonx `TRUNCATE_INPUT_TOKENS`) — PDF hash unchanged but vectors are wrong; see [[watsonx-truncate-input-tokens-rag-trap]]

## Tradeoffs

- **`_collection`** — semi-private API; pin LangChain/Chroma versions in real projects.
- **Delete failures** — log and decide whether to abort; duplicates harm retrieval quality.
- **Same embedding model** — opening store must use the model that created existing vectors.

## Usage notes

- Ingest and chat scripts must share **`persist_directory`** path.
- First run creates `chroma.sqlite3` and index binaries — see [[rag-vector-store-and-ingest-manifest]].
- Batch corpus: each source uses same append path after the first success.

## See also

- [[pluggable-embedding-models]]
- [[rag-ingest-query-settings-parity]]
- [[rag-vector-store-and-ingest-manifest]]