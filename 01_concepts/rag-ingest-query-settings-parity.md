---
title: RAG Ingest and Query Settings Parity
tags:
  - rag
  - embeddings
  - chunking
  - retrieval
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[watsonx-truncate-input-tokens-rag-trap]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[pluggable-embedding-models]]"
  - "[[ingest-manifest-schema-and-fields]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[rag-moc]]"
source:
---

# RAG Ingest and Query Settings Parity

Search only works when **ingest** and **query** use the same rules for turning text into vectors. If ingest used embedding model A with 500-character chunks but chat uses model B or different chunking, similarity scores lie — like measuring with different rulers.

**Layman analogy:** you filed cards with one sorting system; you must search with the **same** system or labels will not line up.

## What must match

| Setting | Why |
|---------|-----|
| **Embedding model** | Different models = incomparable vectors |
| **Chunk size / overlap** | Query embeds a question; index embeds chunks — index geometry must reflect ingest cuts |
| **Persist directory** | Chat opens the store ingest wrote |
| **Metadata keys** | Filters and citations use same field names |

Store chunk parameters in the **manifest** (see [[ingest-manifest-schema-and-fields]]) as documentation of how the index was built.

## Embedding parity

```python
# Ingest
embedding_model = make_embedding_model()
Chroma.from_documents(chunks, embedding_model, persist_directory=str(CHROMA_DIR))

# Query (same factory, same params)
embedding_model = make_embedding_model()
store = Chroma(persist_directory=str(CHROMA_DIR), embedding_function=embedding_model)
```

Changing the embedding API, model version, or **`EMBED_PARAMS`** (including Watsonx truncate) → plan a **full re-ingest** with **`--force`** even when manifest PDF hashes are unchanged. See [[watsonx-truncate-input-tokens-rag-trap]].

### Watsonx trap (summary)

Lab demos may set `TRUNCATE_INPUT_TOKENS: 3` — breaks real RAG. Remove truncate in shared embed config; ingest + chat must match; `--force` re-embed all sources.

## Chunking parity

Ingest splits documents; chat usually embeds the **question** as one string (not split the same way). Parity means: **chunks in the index** were built with the splitter settings your project documents. If you change `chunk_size`, re-embed all sources.

## Constants pattern

```python
CHUNK_SIZE = 500
CHUNK_OVERLAP = 50

# ingest: splitter uses these
# manifest: record version + chunk_size + chunk_overlap on first save
# chat: read same CHROMA_DIR; question embedding only — but document
#        that retrieval assumes index built with these constants
```

## When mismatch bites

- Swapped embedding provider mid-project — retrieval quality collapses until re-ingest.
- Tuned chunk overlap in ingest only — irrelevant for query embed, but old chunks wrong size until re-ingest.
- Two `chroma_01` vs `chroma_02` dirs by mistake — chat searches empty or stale store.

## See also

- [[watsonx-truncate-input-tokens-rag-trap]]
- [[pluggable-embedding-models]]
- [[rag-text-chunking-splitters]]
- [[rag-vector-store-and-ingest-manifest]]
- [[rag-moc]]