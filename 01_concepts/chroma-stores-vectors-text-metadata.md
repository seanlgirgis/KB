---
title: Chroma Stores Vectors, Text, and Metadata
tags:
  - rag
  - chromadb
  - vector-db
  - langchain
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[watsonx-truncate-input-tokens-rag-trap]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[tag-chunks-with-source-metadata]]"
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[rag-moc]]"
source: Distilled from capstone Chroma debug (learning)
---

# Chroma Stores Vectors, Text, and Metadata

A Chroma row (one chunk) holds **three different jobs**. Confusing them makes debugging harder — especially when embeddings are broken but stored text looks fine.

## Three parts per chunk

| Part | Role | Used when |
|------|------|-----------|
| **Vector** | Similarity search index | Retriever embeds the **question**, compares to stored vectors |
| **`page_content`** | Full chunk text (LangChain `Document`) | Passed to LLM in `stuff` chain as **context** |
| **Metadata** | Labels (`ingest_source_id`, page, title, …) | Filter, delete-by-source, citations |

**Layman:** **vector** = fingerprint for finding the card; **page_content** = what’s written on the card; **metadata** = colored dot for which book.

## Common confusion

**“Chunks look full in the DB but search is garbage.”**

- Truncated **embedding input** (e.g. Watsonx `TRUNCATE_INPUT_TOKENS: 3`) warps **vectors only**
- **`page_content`** may still contain the full 500-character split
- Retrieval fails; LLM might still read misleading context if wrong chunks are retrieved

See [[watsonx-truncate-input-tokens-rag-trap]].

## Ingest writes all three

```text
chunk text  →  embed(full or truncated input)  →  vector stored
             →  page_content stored as-is (typical)
             →  metadata stamped at tag step
```

Embed pipeline must match query pipeline — [[rag-ingest-query-settings-parity]].

## Metadata vs manifest

- **Manifest** — per-source ledger (hash, chunk count) — ingest bookkeeping
- **Chunk metadata** — per-chunk labels inside Chroma — retrieval filters and citations

## See also

- [[tag-chunks-with-source-metadata]]
- [[debug-retrieval-without-llm]] — inspect `page_content` previews of hits
- [[rag-moc]]