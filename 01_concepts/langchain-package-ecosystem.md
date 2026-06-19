---
title: LangChain Package Ecosystem (Split Packages)
tags:
  - langchain
  - python
  - rag
  - packages
topics:
  - software-engineering
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[langchain-documents-and-loaders]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[rag-moc]]"
source:
---

# LangChain Package Ecosystem (Split Packages)

Modern LangChain splits across **multiple pip packages** instead of one monolith. RAG ingest scripts typically import loaders and vector stores from **community**, splitters from **text-splitters**, and core abstractions from **langchain-core**.

**Layman analogy:** a toolbox sold as **drawers** — screwdrivers in one, saws in another. You pull from the right drawer instead of one giant chest.

## Common imports map

| Need | Package (typical) | Example import |
|------|-------------------|----------------|
| PDF / web loaders | `langchain-community` | `PyPDFLoader`, `WebBaseLoader` |
| Chroma store | **`langchain-chroma`** | `from langchain_chroma import Chroma` — see [[langchain-chroma-package]] |
| Text splitter | `langchain-text-splitters` | `from langchain_text_splitters import RecursiveCharacterTextSplitter` |
| Document type | `langchain-core` | `from langchain_core.documents import Document` |
| Classic chains | `langchain-classic` | `from langchain_classic.chains import RetrievalQA` |

Exact import paths change across versions — pin versions in project `requirements.txt`.

## Why the split

- Smaller installs for apps that only need splitters
- Community integrations optional (Chroma, dozens of loaders)
- Core types stable while integrations evolve

## Usage notes

- **`langchain` meta-package** — may re-export; prefer explicit package imports in new code.
- **Version skew** — upgrade `langchain-community` and `langchain-text-splitters` together when debugging import errors.
- **Vendor LLM SDKs** — often separate (`openai`, `ibm-watsonx-ai`, etc.) wrapped by your `make_embedding_model()`.

## See also

- [[langchain-chroma-package]]
- [[langchain-documents-and-loaders]]
- [[langchain-rag-chains-overview]]
- [[pluggable-embedding-models]]
- [[python-project-root-for-imports]] — when scripts live in nested folders