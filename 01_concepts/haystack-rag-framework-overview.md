---
title: Haystack RAG Framework Overview
tags:
  - haystack
  - rag
  - search
  - retrieval
  - embeddings
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[rag-framework-ecosystem-comparison]]"
  - "[[rag-pipeline-tool-stages]]"
  - "[[sparse-vs-dense-retrieval-bm25]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[agentic-rag-web-service-stack]]"
  - "[[rag-moc]]"
source: Sean request — Haystack in RAG toolchain context
---

# Haystack RAG Framework Overview

**Haystack** (deepset) is an open-source framework for building **search and RAG pipelines** — composable components for loading, preprocessing, embedding, retrieving, and generating. Strong fit when retrieval quality and **hybrid search** matter as much as the LLM.

**Layman:** an assembly line where each station (load, clean, embed, search, answer) snaps together; tuned for **finding the right paragraph**, not only chatting.

## Core vocabulary map

| Haystack term | Same job as (LangChain kb) |
|---------------|----------------------------|
| **Converter / crawler** | Document loader — [[langchain-documents-and-loaders]] |
| **Preprocessor / splitter** | Chunking — [[rag-text-chunking-splitters]] |
| **Embedder** | Embedding model — [[pluggable-embedding-models]] |
| **Document store** | Vector + optional keyword index | Chroma + manifest — [[rag-vector-store-and-ingest-manifest]] |
| **Retriever** | Fetch ranked documents | Retriever + MMR — [[rag-mmr-retriever]] |
| **Generator** | LLM answer from context | RetrievalQA answer step |
| **Pipeline** | Wired DAG of components | LCEL / chain — [[langchain-lcel-build-sequence]] |

## Typical pipeline

```text
files → converter → preprocessor → embedder → document store
                                                      ↓
question → retriever (BM25 and/or dense) → prompt builder → generator → answer
```

Hybrid **BM25 + embeddings**: [[sparse-vs-dense-retrieval-bm25]], [[retrieval-ranking-pipeline]].

## Advantages

- **Pipeline-first** — clear stages for ops and evaluation
- Strong **keyword + semantic** retrieval story
- Built-in **REST API** for deployment — [[agentic-rag-web-service-stack]]
- Fits teams with search engineering background

## Disadvantages

- Heavier than a two-script capstone for simple PDF RAG
- **Agentic** tool loops are not the main story (contrast [[langchain-agent-patterns-overview]])
- More concepts upfront (components, pipelines, document stores) for beginners

## When to choose Haystack

| Choose | Skip |
|--------|------|
| Production search + RAG with hybrid retrieval | Learning LangChain agents in capstone 04 |
| Measurable retrieval benchmarks drive design | Minimal deps ingest + REPL only |
| Enterprise pipeline YAML/code and REST | LlamaIndex-style index abstractions preferred |

## Comparison

Full three-way table: [[rag-framework-ecosystem-comparison]].

## See also

- [[rag-framework-ecosystem-comparison]]
- [[rag-pipeline-tool-stages]]
- [[sparse-vs-dense-retrieval-bm25]]
- [[rag-moc]]