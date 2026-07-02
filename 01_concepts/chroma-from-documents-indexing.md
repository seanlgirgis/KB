---
title: Chroma from_documents Indexing
tags:
  - rag
  - chromadb
  - langchain
  - embeddings
  - indexing
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-chroma-package]]"
  - "[[chroma-stores-vectors-text-metadata]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-moc]]"
source: Sean paste — M1 pipeline indexing step (Chroma.from_documents)
---

# Chroma from_documents Indexing

`Chroma.from_documents(texts, embeddings)` is the **indexing step**: take **already-split chunks**, **embed** each one, and **store** vectors + text + metadata in Chroma so later queries can search by **meaning**, not exact words.

**Layman:** read every index card, fingerprint its meaning, file it in a smart cabinet. Later you fingerprint the question and pull the closest cards.

```python
from langchain_chroma import Chroma

docsearch = Chroma.from_documents(texts, embeddings)
# capstone: add persist_directory=str(CHROMA_DIR)
```

## What you pass in

| Argument | What it is |
|----------|------------|
| **`texts`** | List of chunks — LangChain **`Document`** objects (`page_content` + `metadata`) |
| **`embeddings`** | Embedding model — e.g. `make_watsonx_embeddings()` / shared factory — [[pluggable-embedding-models]] |

Chunks come from the splitter **before** this call — [[rag-text-chunking-splitters]]. Loaders run earlier — [[langchain-documents-and-loaders]].

Optional capstone arg: **`persist_directory`** — on-disk folder so vectors survive restarts — [[chroma-persist-append-and-reingest]].

## What it does (step by step)

For **each** chunk in `texts`:

```text
1. Take chunk text (page_content)
2. Call embeddings.embed_documents(...)  →  vector (list of floats)
3. Store in Chroma: vector + original text + metadata
```

Not “save text only.” **Embed then store** so similarity search works — [[chroma-stores-vectors-text-metadata]].

## What you get back

`docsearch` is a **Chroma vector store** object (LangChain `VectorStore`):

| Method | Job |
|--------|-----|
| **`docsearch.as_retriever()`** | Adapter for chains — “find chunks similar to this question” — [[langchain-rag-chains-overview]] |
| **`docsearch.similarity_search("mobile policy")`** | Direct debug search — [[debug-retrieval-without-llm]] |

Smoke/lab scripts often use **`.as_retriever()`** inside `RetrievalQA`. MMR tuning: [[rag-mmr-retriever]].

## What it does not do

| Not this step | Owned by |
|---------------|----------|
| Split the document | `RecursiveCharacterTextSplitter` — [[rag-text-chunking-splitters]] |
| Call the LLM | `RetrievalQA` / chat chain — [[langchain-rag-chains-overview]] |
| Download or load the file | `TextLoader`, `PyPDFLoader`, etc. — [[langchain-documents-and-loaders]] |
| Track ingest ledger | Manifest JSON — [[rag-vector-store-and-ingest-manifest]] |

**One line:** chunks in → vectors stored in Chroma → similarity search can find the right chunks later.

## In the ingest pipeline

```text
split (e.g. 16 chunks)  →  Chroma.from_documents  →  "ingest OK"
         ↑                           ↑
    SPLIT stage              EMBED + PERSIST (stages 8–9)
```

Full spine: [[rag-ingest-pipeline-spine]]. First source vs append: [[chroma-persist-append-and-reingest]].

## In-memory vs on-disk

| Mode | When |
|------|------|
| **In-memory** (default, no `persist_directory`) | Fine for one-shot labs — gone when process exits |
| **`persist_directory=...`** | Capstone + production — same API, vectors saved to folder |

Chat must open the **same** path + **same** embed model — [[rag-ingest-query-settings-parity]], [[chroma-dir-version-embedding-provider]].

## Filing-cabinet analogy

| Piece | Role |
|-------|------|
| Chunks | Pages filed |
| Embedding | Fingerprint of each page’s meaning |
| `from_documents` | Fingerprint every page and file it |
| Later query | Fingerprint the question → closest fingerprints → pull those pages |

## See also

- [[langchain-chroma-package]] — import `from langchain_chroma import Chroma`
- [[chroma-persist-append-and-reingest]] — `add_documents`, re-ingest, delete-by-source
- [[retrieval-ranking-pipeline]] — what happens after `as_retriever()` at query time
- [[rag-moc]]