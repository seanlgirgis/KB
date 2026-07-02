---
title: LlamaIndex RAG Framework Overview
tags:
  - llamaindex
  - rag
  - indexing
  - embeddings
topics:
  - retrieval
  - indexing
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[rag-framework-ecosystem-comparison]]"
  - "[[rag-pipeline-tool-stages]]"
  - "[[langchain-package-ecosystem]]"
  - "[[pluggable-embedding-models]]"
  - "[[agentic-rag-web-service-stack]]"
  - "[[rag-moc]]"
source: Sean request — LlamaIndex in RAG toolchain context
---

# LlamaIndex RAG Framework Overview

**LlamaIndex** is a Python framework focused on **connecting LLMs to your data** — building **indexes** from documents, querying them through **query engines**, and layering **agents** on top. Same pipeline stages as LangChain ([[rag-pipeline-tool-stages]]), different vocabulary.

**Layman:** you build a **smart filing system** (index) once; **query engines** are clerks who know how to search it and summarize hits for the LLM.

## Core vocabulary map

| LlamaIndex term | Same job as (LangChain kb) |
|-----------------|----------------------------|
| **Reader / loader** | Document loader — [[langchain-documents-and-loaders]] |
| **Node parser** | Text splitter / chunker — [[rag-text-chunking-splitters]] |
| **Embedding model** | `Embeddings` — [[pluggable-embedding-models]] |
| **Index** | Vector index + metadata over nodes | Chroma collection + manifest |
| **Query engine** | Retriever + synthesizer → answer | RetrievalQA / LCEL RAG — [[langchain-rag-chains-overview]] |
| **Chat engine** | Multi-turn over index | Conversational retrieval |
| **Agent** | Tool-using loop on data | [[langchain-agent-patterns-overview]] |

**Naming trap:** LlamaIndex **node parser** = chunking. LangChain **output parser** = LLM response shape — [[langchain-output-parsers-overview]].

## Typical ingest flow

```text
documents → reader → node parser (chunks) → embed → VectorStoreIndex → persist
```

Query:

```text
question → query_engine.query() → retrieve nodes → LLM response
```

## Advantages

- **Index-first** design — natural for heterogeneous sources (files, APIs, SQL)
- **Query engines** encapsulate retrieve + synthesize without manual chain wiring
- Good sub-question and router patterns for complex corpora
- **LlamaIndex Server** for HTTP — [[agentic-rag-web-service-stack]]

## Disadvantages

- Smaller general **agent/tool** catalog than LangChain for non-RAG automation
- Extra framework if your needs are met by ingest script + RetrievalQA ([[rag-ingest-chat-two-script-architecture]])
- Mixing LlamaIndex index + LangChain agent requires discipline on embed parity — [[rag-ingest-query-settings-parity]]

## When to choose LlamaIndex

| Choose | Skip |
|--------|------|
| Many data types into one query surface | Single PDF corpus + one capstone chat script |
| Query engine abstractions reduce boilerplate | Team already standardized on LangChain/LCEL |
| RAG product centered on “indexes” | Pure agent workflow with RAG as one small tool |

## Comparison

Full three-way table: [[rag-framework-ecosystem-comparison]].

## See also

- [[rag-framework-ecosystem-comparison]]
- [[rag-pipeline-tool-stages]]
- [[langchain-package-ecosystem]] — your primary stack
- [[rag-moc]]