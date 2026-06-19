---
title: LangChain RAG Chains Overview
tags:
  - rag
  - langchain
  - chains
  - lcel
  - retrievalqa
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[retrievalqa-chain-type-packing]]"
  - "[[langchain-package-ecosystem]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source:
---

# LangChain RAG Chains Overview

LangChain offers **many ways** to wire retrieve-then-answer. They share the same RAG idea — find relevant chunks, then let an LLM answer using them — but differ in **packaging era** (classic chains vs LCEL) and **features** (memory, agents, reranking).

**Layman:** same job (librarian + writer), different assembly kits.

## Core pipeline (all patterns)

```text
question → retriever → chunks → LLM → answer
```

Ingest (your vault notes) fills the store; these patterns **read** it at query time.

## Pattern comparison

| Approach | Era / import | Plain English | Typical entry |
|----------|--------------|---------------|---------------|
| **RetrievalQA** | Classic — `langchain_classic.chains` | One class: `qa.invoke(question)` | Capstone chat, lab 31 |
| **LCEL RAG** | Current — `langchain` chains helpers | Composable pipes: `retriever \| prompt \| llm` | Newer course labs |
| **Conversational retrieval** | Classic + memory | RAG plus chat history (“follow-up” questions) | Multi-turn tutors |
| **Agent + tools** | Agents | LLM chooses when to call a search tool | Flexible but less predictable |
| **RAG + reranker** | Add-on stage | Retrieve many → rerank → stuff top hits | Production quality tuning |

## RetrievalQA (what you use now)

```python
from langchain_classic.chains import RetrievalQA

qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
)
answer = qa.invoke("What is RAG?")
```

**Why courses start here:** one object, obvious `invoke`, maps cleanly to “open Chroma → ask questions.”

Packing modes (`stuff`, `map_reduce`, `refine`, `map_rerank`): see [[retrievalqa-chain-type-packing]].

## LCEL RAG (modern packaging)

Same retrieve → answer logic, built from **Runnable** pieces:

```python
# Illustrative — exact imports vary by LangChain version
# create_retrieval_chain(retriever, combine_docs_chain)
# or: prompt | llm  with retriever feeding context
```

**Layman:** LEGO blocks instead of one pre-built toy. More flexible; more pieces to name.

## Classic vs LCEL

| | Classic (`RetrievalQA`) | LCEL |
|--|-------------------------|------|
| **Style** | `from_chain_type`, `.invoke()` | `\|` pipes, `Runnable` |
| **Learning curve** | Lower for first RAG | Higher; closer to production composition |
| **Your capstone** | Chat script | Ingest still uses vector store APIs; chat uses RetrievalQA |

Both can use the same **Chroma** store and **embedding model** — see [[rag-ingest-query-settings-parity]].

## When to pick which (practical)

| Goal | Start with |
|------|------------|
| First working RAG Q&A | **RetrievalQA** + `stuff` |
| Custom prompts / middleware | **LCEL** |
| “What did we talk about earlier?” | **Conversational retrieval** |
| Open-ended tool use | **Agent** (later) |
| Noisy retrieval at scale | **Reranker** after retrieve |

You do **not** need every pattern for capstone completion.

## LangChain wrapper reminder

`vector_store` is a **LangChain `Chroma` object** ([[langchain-package-ecosystem]]). `as_retriever()` is LangChain’s interface; it searches the **Chroma files** ingest created.

## See also

- [[retrievalqa-chain-type-packing]] — four `chain_type` values in depth
- [[pluggable-embedding-models]] — LLM + embeddings in chains
- [[chroma-persist-append-and-reingest]] — store chat opens
- [[rag-moc]]