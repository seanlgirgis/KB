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
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-react-agent-loop]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[conversation-buffer-memory]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[retrievalqa-chain-type-packing]]"
  - "[[langchain-lcel-build-sequence]]"
  - "[[langchain-classic-chains-overview]]"
  - "[[langchain-package-ecosystem]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source:
---

# LangChain RAG Chains Overview

LangChain offers **many ways** to wire retrieve-then-answer. They share the same RAG idea — find relevant chunks, then let an LLM answer using them — but differ in **packaging era** (classic chains vs LCEL) and **features** (memory, agents, reranking).

For **`LLMChain`**, **`SequentialChain`**, and classic chain taxonomy (not RAG-specific), see [[langchain-classic-chains-overview]].

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
| **ConversationChain + buffer** | Classic — `langchain_classic` | Multi-turn chat; **no** retriever — RAM history only | Capstone 03 remember-me |
| **Conversational retrieval** | Classic + memory + retriever | RAG **plus** chat history (“follow-up” questions) | Multi-turn tutors |
| **Agent + ReAct** | `langchain_classic.agents` | LLM Thought → Action → Observation loop | Capstone 04 — [[langchain-react-agent-loop]] |
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

Build sequence and pipe syntax: [[langchain-lcel-build-sequence]].

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
| Session facts only (name, preferences this chat) | **ConversationChain** + buffer — [[conversation-buffer-memory]] |
| “What did we talk about earlier?” **and** corpus docs | **Conversational retrieval** |
| RAG + math + optional skip retrieve | **ReAct agent** — [[fixed-pipeline-vs-langchain-agent]] |
| Open-ended multi-tool routing | **Agent** + tools — [[langchain-react-agent-executor]] |
| Noisy retrieval at scale | **Reranker** after retrieve |

You do **not** need every pattern for capstone completion.

## LangChain wrapper reminder

`vector_store` is a **LangChain `Chroma` object** ([[langchain-package-ecosystem]]). `as_retriever()` is LangChain’s interface; it searches the **Chroma files** ingest created.

## ReAct agent (Capstone 04)

```python
from langchain_classic.agents import AgentExecutor, create_react_agent

executor = AgentExecutor(agent=create_react_agent(llm, tools, prompt), tools=tools)
executor.invoke({"input": "What is 25 + 63?"})
```

RAG as optional tool — not fixed retrieve: [[rag-as-agent-tool]]. Full script: [[langchain-research-agent-repl]].

## ConversationChain (Capstone 03 — not RAG)

```python
from langchain_classic.chains import ConversationChain
from langchain_classic.memory import ConversationBufferMemory

chain = ConversationChain(llm=llm, memory=ConversationBufferMemory(), prompt=...)
chain.invoke(input="My name is Sean")
```

Full REPL + CLI: [[langchain-remember-me-chat-repl]]. Memory types: [[langchain-memory-types-overview]]. JSON persist: [[chat-session-memory-persist-json]]. vs RAG: [[capstone-rag-vs-session-memory]].

## See also

- [[langchain-agent-patterns-overview]]
- [[langchain-react-agent-loop]]
- [[fixed-pipeline-vs-langchain-agent]]
- [[rag-as-agent-tool]]
- [[conversation-buffer-memory]]
- [[langchain-remember-me-chat-repl]]
- [[retrievalqa-chain-type-packing]] — four `chain_type` values in depth
- [[pluggable-embedding-models]] — LLM + embeddings in chains
- [[chroma-persist-append-and-reingest]] — store chat opens
- [[rag-moc]]