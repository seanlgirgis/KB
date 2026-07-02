---
title: Capstone RAG vs Session Memory
tags:
  - rag
  - memory
  - architecture
  - capstone
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[rag-ingest-chat-two-script-architecture]]"
  - "[[conversation-buffer-memory]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[rag-moc]]"
source: Distilled from capstone01 vs capstone03 guides (learning)
---

# Capstone RAG vs Session Memory

Two capstone tracks answer different “remember” questions. **Do not mix them up** in interviews or debugging.

**Layman:** Capstone 01 = librarian with a **filing cabinet** (papers you ingested). Capstone 03 = assistant with a **notepad** (what you said this chat).

## Side-by-side

| | **Capstone 01 — RAG** | **Capstone 03 — memory** |
|--|------------------------|---------------------------|
| **Remembers** | Facts in **documents** | **Your conversation** |
| **Storage** | Chroma on disk (vectors + text) | Python memory in RAM (+ optional JSON) |
| **Search** | Cosine → MMR ([[retrieval-ranking-pipeline]]) | None — full history stuffed in prompt |
| **Survives quit** | Yes (Chroma) | RAM: no · `--save` JSON: yes |
| **Shared module** | `capstone_shared.py` | `watson_llm.py` only (typical) |
| **Chain** | `RetrievalQA` | `ConversationChain` |
| **Embeddings API** | Yes (ingest + query embed) | No for core path |

## Story prompts

| Question | Use |
|----------|-----|
| “What is RAG?” (from papers) | Capstone 01 — needs ingest |
| “What’s my name?” (you said it turn 1) | Capstone 03 — buffer memory |
| “What is RAG?” with **no** Chroma | Capstone 03 — model **weights** only, not your corpus |

## Pipeline contrast

**01:**

```text
question → embed → Chroma retrieve → stuff chunks → LLM
```

**03:**

```text
input → read buffer → prompt(history + input) → LLM → append to buffer
```

## Capstone 04 (agent)

LLM picks tools (RAG + calculator) via **ReAct** — not fixed retrieve every time. Full four-way comparison: [[fixed-pipeline-vs-langchain-agent]].

## Combining later

Production tutors may combine **memory** + **RAG tool** + **utilities** in one agent. Capstones teach each skill alone first.

## See also

- [[fixed-pipeline-vs-langchain-agent]]
- [[langchain-react-agent-loop]]
- [[rag-ingest-chat-two-script-architecture]]
- [[conversation-buffer-memory]]
- [[langchain-remember-me-chat-repl]]
- [[rag-moc]]