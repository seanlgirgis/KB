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
- [[incremental-rag-ingest-build-order]] — bite-by-bite build sequence (learning)

## Foundations

- [[langchain-documents-and-loaders]] — Document, loaders, PDF → pages
- [[langchain-package-ecosystem]] — community, classic, text-splitters, chroma
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

- [[chroma-persist-append-and-reingest]] — `from_documents`, `add_documents`, delete-by-source
- [[rag-vector-store-and-ingest-manifest]] — on-disk layout, ingest vs query

## CLI & batch

- [[ingest-cli-parser-and-handlers]] — `cmd_list`, probe, dispatch
- [[corpus-batch-ingest]] — JSON corpus loop, counts, `quiet_skip`
- [[incremental-rag-web-ingest]] — `web_phase2`, `WebBaseLoader`, `--web`

## Chat (query path)

- [[langchain-rag-chains-overview]] — RetrievalQA, LCEL, conversational, agents, rerank
- [[retrievalqa-chain-type-packing]] — `stuff`, `map_reduce`, `refine`, `map_rerank`
- [[rag-mmr-retriever]] — `search_type="mmr"`, `k` / `fetch_k`
- [[rag-custom-qa-prompt]] — abstain rules, ignore paper Q&A tables
- [[rag-chat-cli-repl]] — argv one-shot + `input()` loop

## Retrieval strategies

- [[rag-troubleshooting-retrieval-first]] — debug retrieval before blaming LLM
- [[debug-retrieval-without-llm]] — **retrieval debugger script** — print hits, cosine compare, no LLM
- [[rag-corpus-coverage-and-abstain]] — corpus gap vs LLM abstain
- [[rag-llm-size-vs-retrieval-quality]] — small LLM OK when retrieval is clean
- [[rag-query-rewrite-for-typos]] — optional rewrite pass before retrieve

## Troubleshooting & Watsonx traps

- [[watsonx-truncate-input-tokens-rag-trap]] — `TRUNCATE_INPUT_TOKENS: 3` breaks search; `--force` fix
- [[chroma-stores-vectors-text-metadata]] — vector vs page_content vs metadata

## Session learnings

- [[incremental-rag-ingest-build-order]]