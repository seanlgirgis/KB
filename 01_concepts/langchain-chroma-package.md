---
title: langchain_chroma Package
tags:
  - concept
  - langchain
  - chroma
  - vector-store
topics:
  - retrieval
  - indexing
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-package-ecosystem]]"
  - "[[chroma-stores-vectors-text-metadata]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[rag-shared-config-module]]"
  - "[[rag-moc]]"
source: Distilled from capstone ingest/chat shared Chroma usage
---

# langchain_chroma Package

**`langchain_chroma`** is the dedicated LangChain integration for **Chroma** vector stores. Import **`Chroma`** from here — not from deprecated **`langchain_community.vectorstores`**.

**Layman:** the official LangChain adapter drawer for Chroma — same filing cabinet, correct handle.

## Import

```python
from langchain_chroma import Chroma
```

## Typical RAG usage

| Operation | API |
|-----------|-----|
| Create + persist | `Chroma.from_documents(docs, embedding, persist_directory=dir)` |
| Load existing | `Chroma(persist_directory=dir, embedding_function=embed)` |
| Retriever | `store.as_retriever(search_type="mmr", search_kwargs={...})` |

Query time must use the **same** `embedding_function` as ingest — see [[rag-ingest-query-settings-parity]].

## vs raw chromadb

| Layer | Role |
|-------|------|
| `chromadb` | Core DB client |
| `langchain_chroma.Chroma` | LangChain `VectorStore` — `similarity_search`, retriever adapters, `from_documents` |

RAG chains and `RetrievalQA` expect the LangChain wrapper.

## Migration note

Older tutorials import `Chroma` from `langchain_community`. New code should use `langchain_chroma`; pin both packages when upgrading.

## See also

- [[langchain-package-ecosystem]]
- [[chroma-persist-append-and-reingest]]
- [[rag-shared-config-module]]
- [[rag-moc]]