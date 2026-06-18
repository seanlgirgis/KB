---
title: RAG MOC
tags:
  - moc
  - rag
topics:
  - retrieval
  - embeddings
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-vector-store-and-ingest-manifest]]"
---

# RAG — Map of Content

Index for retrieval-augmented generation concepts, patterns, and experiments.

## Foundations

- *(add concept notes as you capture them)*

## Chunking & indexing

- [[rag-vector-store-and-ingest-manifest]] — ingest manifest vs vector store dir (dedupe at ingest)
- [[python-hashlib-sha256-fingerprints]] — `content_hash` fingerprints for skip/re-ingest
- [[python-urllib-urls-and-fetching]] — `is_url` guard, fetch URL sources, `source_id`
- [[normalize-source-url-or-local-path]] — stable manifest keys for URL vs file input

## Retrieval strategies

-

## Vector databases

- [[rag-vector-store-and-ingest-manifest]] — persisted Chroma-style dir, on-disk layout, query path

## Tools & frameworks

- LangChain insights may link to notes distilled from `D:\Workarea\learning`

## Session learnings

-