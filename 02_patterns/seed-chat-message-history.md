---
title: Seed ChatMessageHistory for Memory Demos
tags:
  - pattern
  - langchain
  - memory
  - chat
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-remember-me-chat-repl]]"
  - "[[conversation-buffer-memory]]"
  - "[[chat-session-memory-persist-json]]"
  - "[[langchain-package-ecosystem]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03 demo_alice (learning)
---

# Seed ChatMessageHistory for Memory Demos

Pre-load **prior turns** into memory before the first live `invoke` — without typing setup in a REPL. Uses **`ChatMessageHistory`** from community + `chat_memory=` on buffer or summary memory.

**Layman:** start the notepad with “Hello, my name is Alice” already written.

## When to use

| Use | Skip |
|-----|------|
| Scripted demos (`--demo alice`) | Normal REPL from empty |
| Tests that need mid-conversation state | Fresh user sessions |
| Load path after JSON restore | Building history from scratch in REPL |

## Pattern

```python
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_classic.memory import ConversationBufferMemory

history = ChatMessageHistory()
history.add_user_message("Hello, my name is Alice.")
history.add_ai_message("Hello Alice! It's nice to meet you.")

chain = ConversationChain(
    llm=llm,
    memory=ConversationBufferMemory(chat_memory=history),
    prompt=CAPSTONE_PROMPT,
)
# First invoke can ask "What was my favorite color?" after user adds color in later turns
```

Pass the same `chat_memory` into `ConversationSummaryMemory(llm=llm, chat_memory=history)` for summary mode demos.

## Alice demo flow (after seed)

```text
(seed: name = Alice)
→ "My favorite color is blue."
→ "What was my favorite color again?"  → blue
→ "Can you remember both my name and my favorite color?"  → Alice + blue
```

## vs JSON load

| Seed in code | `--load` JSON |
|--------------|---------------|
| Fixed demo script | User’s saved session |
| Same every run | Survives process exit |

Serialize/load: [[chat-session-memory-persist-json]] uses `HumanMessage` / `AIMessage` ↔ `role` dict.

## See also

- [[scripted-multi-turn-chat-demos]]
- [[langchain-remember-me-chat-repl]]
- [[rag-moc]]