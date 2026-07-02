---
title: RAG Pipeline Tool Stages
tags:
  - rag
  - chunking
  - embeddings
  - parsers
  - indexing
topics:
  - retrieval
  - indexing
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[rag-framework-ecosystem-comparison]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[pluggable-embedding-models]]"
  - "[[langchain-output-parsers-overview]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[rag-moc]]"
source: Sean request — chunk/split/parser/embedding tool groups in RAG workflows
---

# RAG Pipeline Tool Stages

Agentic and RAG apps reuse the same **ingest → index → query** building blocks. Frameworks (LangChain, LlamaIndex, Haystack) name them differently, but the **jobs** are stable.

**Layman:** load the book → tear into index cards → stamp each card with coordinates (embed) → file in a cabinet → when asked, find cards → optionally shape the answer (output parser) → LLM writes the reply.

## Stage map (framework-neutral)

| Stage | Job | Your kb depth |
|-------|-----|---------------|
| **Load / parse** | PDF, HTML, markdown → text + metadata | [[langchain-documents-and-loaders]] |
| **Chunk / split** | Cut long text to context-window-sized pieces | [[rag-text-chunking-splitters]] |
| **Embed** | Text → vectors for similarity search | [[pluggable-embedding-models]] |
| **Store** | Persist vectors + text + metadata | [[chroma-persist-append-and-reingest]], [[rag-vector-store-and-ingest-manifest]] |
| **Retrieve** | Query → ranked chunks | [[retrieval-ranking-pipeline]], [[rag-mmr-retriever]] |
| **Generate** | Chunks + question → LLM answer | [[langchain-rag-chains-overview]] |
| **Output parse** (optional) | Raw LLM text → list, JSON, typed object | [[langchain-output-parsers-overview]] |
| **Agent loop** (optional) | LLM picks tools (RAG, calculator, APIs) | [[langchain-agent-patterns-overview]] |

Full ingest order: [[rag-ingest-pipeline-spine]]. CLI split (ingest vs chat): [[rag-ingest-chat-two-script-architecture]].

## Chunk vs split vs parse (often confused)

| Term | Meaning |
|------|---------|
| **Document parsing** | Extract text from PDF/DOCX/HTML (loader, reader, converter) |
| **Chunking / splitting** | Subdivide extracted text for embedding and retrieval |
| **Output parsing** | Structure the **LLM’s answer** (comma list, JSON, Pydantic) — not PDF parsing |

“Parser” in LangChain often means **LLM output parser** — [[langchain-output-parsers-overview]]. “Parser” in LlamaIndex often means **node parser** (chunking). Same word, different layer.

## Embedding layer (shared concern)

Every framework needs **one embed model** for ingest and query — [[rag-ingest-query-settings-parity]]. Libraries:

- Framework wrappers (LangChain `Embeddings`, LlamaIndex `Embedding`, Haystack components)
- Direct: OpenAI API, Watsonx, **`sentence-transformers`** (local models)

Swapping embed provider without re-chunking wrong index: [[chroma-dir-version-embedding-provider]].

## Where frameworks differ

They bundle the same stages with different **defaults, naming, and opinions**:

| Framework | Emphasis |
|-----------|----------|
| **LangChain** | Composable chains, agents, huge integration surface |
| **LlamaIndex** | Index + query engines, data-centric RAG |
| **Haystack** | Search pipelines, production retrieval |

Pick-by-tradeoff: [[rag-framework-ecosystem-comparison]].

## See also

- [[rag-framework-ecosystem-comparison]] — LangChain vs LlamaIndex vs Haystack
- [[langchain-package-ecosystem]] — LangChain package map for each stage
- [[agentic-rag-web-service-stack]] — expose finished pipeline over HTTP
- [[rag-moc]]