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
updated: 2026-06-19
related:
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-vector-store-and-ingest-manifest]]"
---

# RAG — Map of Content

Index for retrieval-augmented generation concepts, patterns, and experiments.

## Pipeline (start here)

- [[rag-ingest-pipeline-spine]] — resolve → hash → manifest → split → embed → persist
- [[rag-ingest-chat-two-script-architecture]] — ingest + chat + shared + debug roles
- [[agentic-rag-web-service-stack]] — expose RAG/agents as HTTP (FastAPI, LangServe, vLLM, Ollama)
- [[incremental-rag-ingest-build-order]] — bite-by-bite build sequence (learning)

## Frameworks & pipeline stages

- [[rag-pipeline-tool-stages]] — **start here** — load, chunk, embed, store, retrieve, output parse
- [[rag-framework-ecosystem-comparison]] — LangChain vs LlamaIndex vs Haystack — pros/cons
- [[llamaindex-rag-framework-overview]]
- [[haystack-rag-framework-overview]]
- [[langchain-package-ecosystem]] — LangChain split packages (your primary stack)

## Foundations

- [[langchain-documents-and-loaders]] — Document, loaders, PDF → pages
- [[langchain-chroma-package]] — `from langchain_chroma import Chroma`
- [[pluggable-embedding-models]] — embed factory for ingest and query
- [[rag-ingest-query-settings-parity]] — same model, chunk constants, persist path
- [[rag-shared-config-module]] — one module for paths, embed params, Chroma helpers

## Chunking & indexing

- [[rag-text-chunking-splitters]] — `RecursiveCharacterTextSplitter`, size, overlap
- [[tag-chunks-with-source-metadata]] — `ingest_source_id` on every chunk
- [[read-source-bytes-and-loader-path]] — PDF vs web bytes, `kind`, loader path
- [[ingest-manifest-schema-and-fields]] — manifest JSON contract
- [[rag-vector-store-and-ingest-manifest]] — vector dir vs manifest ledger
- [[python-hashlib-sha256-fingerprints]] — `content_hash`
- [[normalize-source-url-or-local-path]] — canonical `source_id`
- [[python-urllib-urls-and-fetching]] — `is_url`, `urlopen`
- [[python-json-read-write-files]] — save/load ledger

## Vector databases

- [[chroma-from-documents-indexing]] — **what `from_documents` does** — args, embed loop, retriever
- [[chroma-persist-append-and-reingest]] — `from_documents`, `add_documents`, delete-by-source
- [[rag-vector-store-and-ingest-manifest]] — on-disk layout, ingest vs query

## CLI & batch

- [[ingest-cli-parser-and-handlers]] — `cmd_list`, probe, dispatch
- [[corpus-batch-ingest]] — JSON corpus loop, counts, `quiet_skip`
- [[incremental-rag-web-ingest]] — `web_phase2`, `WebBaseLoader`, `--web`

## LangChain chains

- [[langchain-lcel-build-sequence]] — **LCEL start** — template → PromptTemplate → `\|` chain → `invoke`
- [[langchain-output-parsers-overview]] — `StrOutputParser`, `CommaSeparatedListOutputParser`, JSON
- [[langchain-few-shot-prompt-template]] — example shots to guide LLM output
- [[langchain-classic-chains-overview]] — **LLMChain**, **SequentialChain**, SimpleSequential, map to capstones
- [[langchain-sequential-chain-review-pipeline]] — 3-step review desk (Capstone 02 / Lab 34)
- [[langchain-rag-chains-overview]] — RetrievalQA, LCEL, conversational, agents, rerank
- [[retrievalqa-chain-type-packing]] — `stuff`, `map_reduce`, `refine`, `map_rerank`
- [[rag-mmr-retriever]] — `search_type="mmr"`, `k` / `fetch_k`
- [[rag-custom-qa-prompt]] — abstain rules, ignore paper Q&A tables
- [[rag-chat-cli-repl]] — argv one-shot + `input()` loop

## Retrieval ranking (how chunks are picked)

- [[retrieval-ranking-pipeline]] — **start here** — query vector → cosine → fetch_k → MMR → LLM
- [[sparse-vs-dense-retrieval-bm25]] — BM25 keyword vs dense embeddings (fourth comparison)
- [[dense-passage-retrieval-dpr]] — DPR paper; bi-encoder pattern
- [[cosine-similarity-vector-retrieval]] — score chunks; toy 3-dim demo + Watsonx debug
- [[rag-mmr-retriever]] — `k` / `fetch_k`, diversity after cosine

## Retrieval strategies

- [[rag-troubleshooting-retrieval-first]] — debug retrieval before blaming LLM
- [[debug-retrieval-without-llm]] — **retrieval debugger script** — print hits, cosine compare, no LLM
- [[rag-corpus-coverage-and-abstain]] — corpus gap vs LLM abstain
- [[rag-llm-size-vs-retrieval-quality]] — small LLM OK when retrieval is clean
- [[rag-query-rewrite-for-typos]] — optional rewrite pass before retrieve

## Troubleshooting & Watsonx traps

- [[watsonx-truncate-input-tokens-rag-trap]] — `TRUNCATE_INPUT_TOKENS: 3` breaks search; `--force` fix
- [[chroma-stores-vectors-text-metadata]] — vector vs page_content vs metadata

## Agents & ReAct (Capstone 04)

- [[langchain-agent-patterns-overview]] — **start here** — pattern map, choosing a pattern, LangGraph, RAG flows
- [[langchain-react-agent-loop]] — ReAct loop — Thought → Action → Observation → Final Answer
- [[fixed-pipeline-vs-langchain-agent]] — chain vs agent; capstones 01–04 table
- [[langchain-tool-calling-vs-react]] — structured tool calls vs text ReAct
- [[langchain-react-agent-executor]] — `create_react_agent`, prompt, guardrails
- [[langchain-agent-llm-vs-chat-llm]] — `make_watsonx_agent_llm`, `stop` trap
- [[chroma-dir-version-embedding-provider]] — new `CHROMA_DIR` after embed swap
- [[rag-as-agent-tool]] — retriever as optional tool (not nested RetrievalQA)
- [[langchain-agent-tool-input-sanitization]] — `_first_line` for calculator
- [[langchain-research-agent-repl]] — script shape, smoke tests, REPL
- [[capstone-04-research-agent-2026-06-19]] — bites, done-when
- [[rag-adaptive-self-crag-flows]] — adaptive / self-RAG / CRAG (conceptual; LangGraph)

## Conversational memory (Capstone 03)

- [[capstone-rag-vs-session-memory]] — **start here** — 01 RAG vs 03 session memory
- [[conversation-buffer-memory]] — buffer RAM, growth limits
- [[langchain-memory-types-overview]] — buffer / window / summary
- [[langchain-remember-me-chat-repl]] — bare + full CLI, demos, traps
- [[chat-session-memory-persist-json]] — `--save` / `--load` JSON
- [[conversation-summary-memory]] — `--memory summary`, replay on load
- [[seed-chat-message-history]] — Alice demo pre-load
- [[scripted-multi-turn-chat-demos]] — `--demo cat` / `alice`
- [[bare-vs-full-script-tier]] — bare vs full py pair
- [[suppress-langchain-classic-deprecation-warnings]] — lab noise filter
- [[capstone-03-remember-me-complete-2026-06-19]] — scripts, bites, done-when

## Session learnings

- [[incremental-rag-ingest-build-order]]
- [[capstone-03-remember-me-complete-2026-06-19]]