---
title: LangChain Memory Types Overview
tags:
  - langchain
  - memory
  - chat
  - llm
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[conversation-buffer-memory]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[chat-session-memory-persist-json]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from Capstone 03 guide + remember-me chat (learning)
---

# LangChain Memory Types Overview

LangChain classic memory classes decide **what prior turns** get injected into the next prompt. Capstone 03 starts with **buffer** (full transcript); stretch adds **summary** and optional **window**.

**Layman:** buffer = full diary every turn; summary = diary compressed to bullet points; window = only the last few pages.

## Read and write for continuity

LangChain memory **reads** prior turns into the prompt and **writes** new user/assistant lines after each call — that **read/write cycle** preserves **continuity across interactions**. The LLM itself is stateless; memory is the session-side cache that makes multi-turn chat feel coherent.

```text
read history → build prompt → LLM → save_context (write new turns)
```

Not the same as vector RAG ([[capstone-rag-vs-session-memory]]) — memory holds **dialogue**, not indexed documents.

## Comparison

| Type | Compresses? | Good for | Risk |
|------|-------------|----------|------|
| **`ConversationBufferMemory`** | No — full text each turn | Learning, short REPL, demos | Prompt grows → slow, costly, context errors |
| **`ConversationBufferWindowMemory`** | Drops old turns (keep last K) | Long chat, fixed window | Forgets early facts |
| **`ConversationSummaryMemory`** | LLM summarizes history | Long sessions, save tokens | Extra LLM call; empty session needs chat first |

Imports (classic):

```python
from langchain_classic.memory import (
    ConversationBufferMemory,
    ConversationSummaryMemory,
)
```

## What gets sent each turn (buffer)

LLMs are **stateless** — each API call only sees what you send **that call**.

Without memory:

```text
You: My name is Sean.
AI: Hi Sean!
You: What's my name?
AI: I don't know.    ← only last question was in the payload
```

With buffer memory:

```text
Each invoke sends:  [full chat history string] + [new user line]
AI can answer:      What's my name? → Sean
```

That history is **session cache in RAM** — not Chroma. See [[conversation-buffer-memory]].

## Inside ConversationChain (one invoke)

```text
memory read  →  prompt(history + input)  →  LLM  →  memory save_context
```

`ConversationChain` hides manual message list wiring; Lab 33 may show manual history first as contrast.

## Buffer growth trap

Hours or hundreds of turns with **buffer only** → prompt explodes → latency, cost, truncation, or “forgetting.” Plan **summary** or **window** for production; buffer is fine for capstone-scale REPL.

## Summary memory detail

`ConversationSummaryMemory` — empty-session trap, load replay, `--memory summary`: [[conversation-summary-memory]].

## Seeding history (Alice demo pattern)

Pre-load turns with `ChatMessageHistory` + `chat_memory=`: [[seed-chat-message-history]].

## See also

- [[conversation-buffer-memory]]
- [[chat-session-memory-persist-json]] — survive `quit` via JSON, not vectors
- [[langchain-remember-me-chat-repl]]
- [[rag-moc]]