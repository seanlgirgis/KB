---
title: Chroma Directory Version per Embedding Provider
tags:
  - pattern
  - rag
  - chromadb
  - embeddings
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[rag-shared-config-module]]"
  - "[[rag-ingest-query-settings-parity]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-as-agent-tool]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[rag-moc]]"
source: Distilled from capstone_shared chroma_01_openai + provider swap (learning)
---

# Chroma Directory Version per Embedding Provider

When you **change embedding provider or model**, point `CHROMA_DIR` at a **new folder** and **re-ingest**. Old vectors are not compatible with new query embeddings — mixing causes empty or nonsense retrieval.

**Layman:** new translation machine → new filing cabinet drawer; old cards use the old coordinate system.

## Pattern

```python
# shared config — name folder after provider generation
CHROMA_DIR = CAPSTONE_DIR / "data" / "chroma_01_openai"
# was: chroma_01 for Watson-era vectors
```

| Situation | Action |
|-----------|--------|
| Swapped OpenAI ↔ Watsonx (or model id change) | New `CHROMA_DIR` suffix + full re-embed |
| `chroma_has_data()` false but you ingested “before” | Data may be in **old** path — code reads **new** path |
| Manifest says unchanged | Still need **`--force`** to populate new dir |

```text
python capstone_01_ingest.py --corpus --force
```

## Symptom: agent / chat “no vector store”

| You see | Likely cause |
|---------|----------------|
| `No vector store at .../chroma_01_openai` | Ingest never run to **new** dir |
| Old `chroma_01/` exists on disk | Provider swap without re-ingest |

Fix: `--corpus --force` into current `CHROMA_DIR` from [[rag-shared-config-module]].

## Agent capstone dependency

Capstone 04 `require_chroma()` gates on the **same** `CHROMA_DIR` as Capstone 01 chat — [[rag-as-agent-tool]].

## See also

- [[rag-ingest-query-settings-parity]]
- [[watsonx-truncate-input-tokens-rag-trap]] — different issue (params), same “re-embed” fix
- [[rag-moc]]