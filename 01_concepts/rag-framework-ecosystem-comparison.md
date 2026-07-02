---
title: RAG Framework Ecosystem Comparison
tags:
  - rag
  - langchain
  - llamaindex
  - haystack
  - architecture
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[rag-pipeline-tool-stages]]"
  - "[[langchain-package-ecosystem]]"
  - "[[llamaindex-rag-framework-overview]]"
  - "[[haystack-rag-framework-overview]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[agentic-rag-web-service-stack]]"
  - "[[rag-moc]]"
source: Sean request — framework pros/cons for chunk/split/embed/RAG/agent workflows
---

# RAG Framework Ecosystem Comparison

**LangChain**, **LlamaIndex**, and **Haystack** all implement the same RAG stages ([[rag-pipeline-tool-stages]]) with different packaging. None replaces a vector DB (Chroma, Pinecone, Qdrant, Weaviate) or an LLM host — they **orchestrate** load → split → embed → retrieve → generate (and optionally **agents**).

**Layman:** three kitchen layouts for the same recipe — same ingredients (docs, embed model, vector store, LLM), different counter arrangement and specialty tools.

## Quick pick

| You need… | Lean toward |
|-----------|-------------|
| Course/capstone alignment, agents + LCEL + many integrations | **LangChain** — [[langchain-package-ecosystem]] |
| Index-first RAG, query engines, data connectors | **LlamaIndex** — [[llamaindex-rag-framework-overview]] |
| Production search/RAG pipelines, BM25 + dense hybrid | **Haystack** — [[haystack-rag-framework-overview]] |
| Minimal framework, own scripts | **Your two-script pattern** — [[rag-ingest-chat-two-script-architecture]] |
| HTTP product wrapper | **FastAPI + any framework** — [[agentic-rag-web-service-stack]] |

## Side-by-side (2025–2026)

| Dimension | LangChain | LlamaIndex | Haystack |
|-----------|-----------|------------|----------|
| **Center of gravity** | Chains, LCEL, agents, tools | Indexes, query engines, agents on data | Pipelines, retrieval, evaluation |
| **Chunk / split** | `langchain-text-splitters` | Node parsers, sentence splitters | Preprocessors, converters |
| **Load / parse docs** | `langchain-community` loaders | Readers + node parsers | File converters, crawlers |
| **Embeddings** | `Embeddings` interface + integrations | `Embedding` on index build | Embedder components in pipeline |
| **Vector stores** | Chroma, many via community | Many vector store adapters | Document stores + retrievers |
| **Query** | Retrievers, LCEL, RetrievalQA | Query engines, chat engines | Pipelines with retriever + generator |
| **Agents** | Strong — ReAct, LangGraph, tool calling | Agents / workflows on indices | Less agent-first; pipeline composition |
| **Serving** | LangServe + FastAPI | LlamaIndex Server | REST API built-in |
| **Ecosystem size** | Largest integration catalog | RAG/data focused | Strong in enterprise search |
| **Learning curve** | Wide — many packages | Medium — index concepts | Medium — pipeline YAML/code |
| **Your vault** | Primary — capstones, notes | Comparison / alternative | Comparison / alternative |

## Advantages and disadvantages

### LangChain

**Pros**

- Widest loader and vector-store integrations
- Mature **agent** story (classic + LangGraph) — [[langchain-agent-patterns-overview]]
- LCEL composition — [[langchain-lcel-build-sequence]]
- Matches your labs and kb depth

**Cons**

- Split packages and fast API churn — [[langchain-package-ecosystem]]
- Easy to over-abstract; import/version debugging
- “LangChain” alone does not mean one pip install

### LlamaIndex

**Pros**

- **Index-centric** mental model — good when data shapes vary (PDF tree, SQL, APIs)
- Query engines and composable retrievers without hand-wiring every chain
- Strong docs for RAG-specific patterns (sub-question, routing)

**Cons**

- Smaller agent/tool ecosystem than LangChain for general automation
- Another abstraction layer if you only need simple Chroma + one chain
- Overlap with LangChain — teams sometimes mix both (extra dependency weight)

### Haystack

**Pros**

- **Pipeline** model fits search teams and eval-driven iteration
- First-class **sparse + dense** (BM25 + embeddings) — [[sparse-vs-dense-retrieval-bm25]]
- REST API and production deployment story

**Cons**

- Heavier for small scripts or course-scale prototypes
- Agentic loops less central than LangChain
- Steeper if you only want “ingest PDF → chat”

## Adjacent tools (not full frameworks)

| Tool | Role | vs main three |
|------|------|----------------|
| **Chroma** | Vector database | Storage layer — used *by* frameworks — [[langchain-chroma-package]] |
| **sentence-transformers** | Local embedding models | Embed engine behind any framework |
| **Unstructured** | Heavy document parsing (PDF/layout) | Upstream of chunking; pairs with any framework |
| **LangGraph** | Stateful agent graphs | Often **with** LangChain, not a rival RAG stack |
| **txtai** | Embeddings + semantic search + optional agents | Lighter all-in-one; smaller community |

## Mixing frameworks (pragmatic rule)

| OK | Risky |
|----|-------|
| One framework for orchestration + Chroma + your embed factory | Two frameworks both owning chunk+embed+store (duplicate abstractions) |
| Unstructured for hard PDFs + LangChain for chain/agent | LlamaIndex index + LangChain agent on different embed models without parity |

Keep **one embed model + one chunk policy** per index — [[rag-ingest-query-settings-parity]].

## Mapping to your capstones

| Capstone piece | LangChain (your stack) | LlamaIndex analogue | Haystack analogue |
|----------------|------------------------|---------------------|-------------------|
| Ingest | Loaders + splitter + Chroma | Reader + node parser + index | Converter + preprocessor + document store |
| Chat | RetrievalQA / retriever | Query engine | Retrieval pipeline + generator |
| Agent | ReAct + tools | Agent + tools on index | Custom pipeline steps |
| Output shape | Output parsers | Response synthesizers | Structured answers in pipeline |

## See also

- [[rag-pipeline-tool-stages]] — load, split, embed, parse stages
- [[llamaindex-rag-framework-overview]]
- [[haystack-rag-framework-overview]]
- [[langchain-package-ecosystem]]
- [[rag-moc]]