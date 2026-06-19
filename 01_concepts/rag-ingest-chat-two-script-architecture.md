---
title: RAG Ingest and Chat Two-Script Architecture
tags:
  - rag
  - architecture
  - ingestion
  - retrieval
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[rag-shared-config-module]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from two-script + shared module pattern (learning capstone)
---

# RAG Ingest and Chat Two-Script Architecture

Production-shaped RAG prototypes split into **prepare once** (ingest) and **ask many times** (chat), plus optional **debug retrieval** and a **shared config** module. Same idea as real apps: ETL pipeline vs query API.

**Layman:** Script A files books in the cabinet; Script B only asks questions across all filed books; Script C shows which cards were pulled — without calling the writer.

## Four roles (generalized)

| Role | Job | Reads manifest? | Calls LLM? |
|------|-----|-----------------|------------|
| **Ingest** | PDF/web → chunk → embed → Chroma + manifest | Read/write | Embed API only |
| **Chat** | Open Chroma → retrieve → answer | No | Yes (generation) |
| **Shared config** | Paths, embed params, Chroma helpers | — | — |
| **Debug retrieval** | Print top-k chunks for a question | No | No |

## Data flow

```text
INGEST (many sources over time)
  source → hash → manifest skip?
       → load/split/tag → embed → Chroma persist
       → update manifest

CHAT (many questions)
  open Chroma (shared path + embed model)
       → retriever → RetrievalQA → answer

DEBUG (when chat looks wrong)
  open Chroma → retriever.invoke → print previews (no LLM)
```

## Libraries by script

| Layer | Ingest | Chat | Shared |
|-------|--------|------|--------|
| Loaders | `PyPDFLoader`, `WebBaseLoader` | — | — |
| Split | `RecursiveCharacterTextSplitter` | — | constants |
| Store | [[langchain-chroma-package]] `Chroma` | `Chroma` load | open/load helpers |
| CLI | `argparse` `--corpus`, `--web`, `--list` | argv + `input()` loop | — |
| Chain | — | `RetrievalQA`, `PromptTemplate` | — |
| Ledger | `json` manifest | — | `MANIFEST_PATH` |

## KB coverage map

| Technique | Note |
|-----------|------|
| Pipeline spine | [[rag-ingest-pipeline-spine]] |
| Shared module | [[rag-shared-config-module]] |
| Manifest + Chroma | [[rag-vector-store-and-ingest-manifest]] |
| PDF vs web bytes | [[read-source-bytes-and-loader-path]], [[incremental-rag-web-ingest]] |
| Chroma package | [[langchain-chroma-package]] |
| MMR retriever | [[rag-mmr-retriever]] |
| Custom QA prompt | [[rag-custom-qa-prompt]] |
| Debug script | [[debug-retrieval-without-llm]] |
| Troubleshooting | [[rag-troubleshooting-retrieval-first]] |
| Watsonx embed trap | [[watsonx-truncate-input-tokens-rag-trap]] |
| Chat CLI | [[rag-chat-cli-repl]] |

## Run order

```text
1. ingest --corpus   (PDF tier)
2. ingest --web      (HTML tier, optional)
3. ingest --list     (sanity)
4. debug_retrieval   (optional, before chat tuning)
5. chat              (questions)
```

## See also

- [[rag-moc]]