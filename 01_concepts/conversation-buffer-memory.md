---
title: Conversation Buffer Memory
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
  - "[[langchain-memory-types-overview]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[chat-session-memory-persist-json]]"
  - "[[capstone-rag-vs-session-memory]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from Capstone 03 remember-me chat (learning)
---

# Conversation Buffer Memory

**Conversation buffer memory** keeps the full text of prior turns in **RAM** for the current Python process. Each `invoke` sends **history + new input** to the LLM. It is **not** Chroma — no embeddings, no cosine search.

**Layman:** sticky note on the desk for **this phone call** — not the filing cabinet ([[capstone-rag-vs-session-memory]]).

## What it stores

| Stored | Not stored |
|--------|------------|
| Prior Human/AI lines in `chain.memory.buffer` | Chunk vectors |
| Session facts (“my name is Sean”) | Ingested PDF corpus |
| Grows every turn (no compression) | Survives quit **unless** you `--save` JSON |

Proof: turn 1 name → turn 2 “Who am I?” → **Sean**.

## Persistence layers

| Layer | Survives quit? |
|-------|----------------|
| **Buffer RAM** | No |
| **`--save` JSON** | Yes — [[chat-session-memory-persist-json]] |
| **Chroma** | Yes — different feature (RAG docs) |

## vs Capstone 01 RAG

Full table: [[capstone-rag-vs-session-memory]]. Short: 01 retrieves **documents**; 03 replays **chat transcript** in the prompt.

## LangChain wiring

```python
from langchain_classic.chains import ConversationChain
from langchain_classic.memory import ConversationBufferMemory

chain = ConversationChain(
    llm=llm,
    memory=ConversationBufferMemory(),
    prompt=prompt_with_history_and_input,  # {history}, {input}
    verbose=False,
)
result = chain.invoke(input="What's my name?")
```

Build chain **once** before REPL — new chain per loop iteration wipes memory.

## Growth limit

Unbounded buffer → huge prompts → slow, expensive, truncated context. Alternatives: [[langchain-memory-types-overview]] (summary, window).

## Done-when (Capstone 03)

- REPL until quit; name recall across turns
- Explain: buffer = RAM session cache, not Chroma
- Explain: quit drops RAM; optional JSON save is separate from vectors

## See also

- [[langchain-remember-me-chat-repl]] — bare + full CLI, traps, demos
- [[langchain-memory-types-overview]]
- [[chat-session-memory-persist-json]]
- [[rag-moc]]