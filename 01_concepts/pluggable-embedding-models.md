---
title: Pluggable Embedding Models in RAG
tags:
  - rag
  - embeddings
  - langchain
  - llm
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[rag-pipeline-tool-stages]]"
  - "[[rag-framework-ecosystem-comparison]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[rag-ingest-query-settings-parity]]"
  - "[[langchain-package-ecosystem]]"
  - "[[rag-moc]]"
source:
---

# Pluggable Embedding Models in RAG

**Embeddings** turn text into numeric vectors for similarity search. RAG pipelines treat the embedding step as a **pluggable function**: same interface for ingest (many chunks) and query (usually one question string). The concrete provider — OpenAI, Watsonx, local sentence-transformers — hides behind a factory your project calls in one place.

**Layman analogy:** a **translation machine** converts every index card and every question into coordinates on a map. Ingest and search must use the **same machine** or coordinates are meaningless.

## Core idea

```python
def make_embedding_model():
    """Return object with .embed_documents(texts) and .embed_query(text)."""
    ...


embedding_model = make_embedding_model()
vectors = embedding_model.embed_documents(["chunk one", "chunk two"])
query_vec = embedding_model.embed_query("What is RAG?")
```

LangChain vector stores accept an `embedding_function` / `embedding` argument wrapping that behavior.

## Provider-specific params

Cloud APIs may need extra options (truncation, return options, API keys via env). Keep params in **one module** next to `make_embedding_model()` — not scattered in ingest and chat.

```python
# Illustrative — names vary by provider
EMBED_PARAMS = {
    "truncate_input_tokens": 512,
    "return_options": {"input_text": True},
}

def make_embedding_model():
    return MyProviderEmbeddings(**EMBED_PARAMS)
```

Secrets stay in environment variables or local config — never in kb notes.

## When to swap providers

- Course lab uses vendor A; production uses vendor B → new factory, **full re-ingest**.
- Model version bump from provider → treat as new index generation.

## When not to abstract yet

- Single throwaway script — inline embed call is fine until you add a chat script.

## Usage notes

- **Cost** — embed calls dominate ingest bills; manifest skip saves repeats.
- **Batching** — some APIs embed many texts per request; check provider docs.
- **Dimension** — vector size is model-specific; cannot mix models in one collection.

## See also

- [[rag-ingest-query-settings-parity]]
- [[chroma-persist-append-and-reingest]]
- [[rag-vector-store-and-ingest-manifest]]