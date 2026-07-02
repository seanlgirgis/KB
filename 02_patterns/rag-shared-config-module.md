---
title: RAG Shared Config Module
tags:
  - pattern
  - rag
  - python
  - configuration
topics:
  - software-engineering
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[rag-ingest-query-settings-parity]]"
  - "[[rag-ingest-chat-two-script-architecture]]"
  - "[[python-project-root-for-imports]]"
  - "[[pluggable-embedding-models]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[langchain-chroma-package]]"
  - "[[rag-moc]]"
source: Distilled from shared config module pattern (learning capstone)
---

# RAG Shared Config Module

Split **ingest** and **chat** into two scripts, but extract **one shared module** for paths, chunk constants, embedding factory, and Chroma open/load helpers. Prevents the most common RAG bug: ingest and query using different directories or embed settings.

**Layman:** one settings sheet on the wall — both the filing clerk and the librarian read the same sheet.

## What belongs in shared config

| Export | Used by |
|--------|---------|
| `CHROMA_DIR`, `MANIFEST_PATH`, `CORPUS_PATH` | Ingest (+ chat reads `CHROMA_DIR`) |
| `CHUNK_SIZE`, `CHUNK_OVERLAP`, `METADATA_SOURCE_KEY` | Ingest; documented for chat parity |
| `EMBED_PARAMS` + `make_embedding_model()` | Ingest embed + chat query embed |
| `chroma_has_data()`, `open_vector_store()`, `load_vector_store()` | Ingest append + chat load |
| `sys.path` fix for parent package imports | All scripts in nested folder |

**Keep out of shared:** manifest read/write orchestration, CLI handlers, `RetrievalQA`, PDF/web load helpers — those stay in ingest or chat.

**Provider swap:** bump `CHROMA_DIR` when embedding provider changes — [[chroma-dir-version-embedding-provider]]. Capstone 04 agent reads the same path as 01 chat.

## Example skeleton

```python
# shared_rag_config.py
from pathlib import Path
import sys

_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

CHROMA_DIR = Path(__file__).resolve().parent / "data" / "chroma"
MANIFEST_PATH = CHROMA_DIR.parent / "ingest_manifest.json"
CHUNK_SIZE = 500
CHUNK_OVERLAP = 50
METADATA_SOURCE_KEY = "ingest_source_id"

EMBED_PARAMS = { ... }  # same in ingest and chat — see watsonx-truncate trap


def make_embedding_model():
    return make_embeddings(EMBED_PARAMS)


def chroma_has_data() -> bool:
    return CHROMA_DIR.exists() and any(CHROMA_DIR.iterdir())


def load_vector_store():
    if not chroma_has_data():
        raise FileNotFoundError(f"No store at {CHROMA_DIR}. Run ingest first.")
    from langchain_chroma import Chroma
    return Chroma(persist_directory=str(CHROMA_DIR), embedding_function=make_embedding_model())
```

## Import discipline

```python
# ingest.py
from shared_rag_config import CHROMA_DIR, make_embedding_model, open_vector_store

# chat.py
from shared_rag_config import CHROMA_DIR, chroma_has_data, load_vector_store
```

**Never duplicate** `CHROMA_DIR` or `EMBED_PARAMS` literals in chat.

## See also

- [[rag-ingest-chat-two-script-architecture]]
- [[rag-ingest-query-settings-parity]]
- [[watsonx-truncate-input-tokens-rag-trap]]
- [[rag-moc]]