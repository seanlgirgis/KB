---
title: Conversation Summary Memory
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
  - "[[conversation-buffer-memory]]"
  - "[[chat-session-memory-persist-json]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03_remember_me_chat.py --memory summary (learning)
---

# Conversation Summary Memory

**`ConversationSummaryMemory`** compresses chat history with an **LLM** instead of stuffing the full transcript each turn. Capstone 03 stretch: `--memory summary` on the full remember-me script.

**Layman:** diary summarized to bullet points before each new question — saves space, costs an extra model call.

## vs buffer

| | Buffer | Summary |
|--|--------|---------|
| **Prompt each turn** | Full transcript | Running summary string |
| **Extra LLM** | No | Yes (summarize step) |
| **Empty new session** | Works immediately | **Trap:** no history to summarize — chat first or `--load` |

## Wiring

Summary memory needs the **same LLM** (or another) passed into the memory object:

```python
from langchain_classic.memory import ConversationSummaryMemory

memory = ConversationSummaryMemory(llm=make_chat_llm())
chain = ConversationChain(llm=make_chat_llm(), memory=memory, prompt=CAPSTONE_PROMPT)
```

Optional pre-seeded messages: `ConversationSummaryMemory(llm=llm, chat_memory=history)`.

## Empty session trap

Starting summary mode with no prior turns:

```text
Summary memory: empty session — tell me your name first, or use --load ...
```

Turn 1 “don’t know” on recall is often **empty summary**, not broken wiring.

## Load + replay

After `--load` JSON into summary memory, messages restore into `ChatMessageHistory` but internal **summary state** may still be stale. **Replay** human/ai pairs through `save_context`:

```python
def replay_summary_from_messages(chain, rows: list[dict]) -> None:
    if not isinstance(chain.memory, ConversationSummaryMemory):
        return
    pending_human = None
    for row in rows:
        if row["role"] == "human":
            pending_human = row["content"]
        elif row["role"] == "ai" and pending_human is not None:
            chain.memory.save_context(
                {"input": pending_human},
                {"output": row["content"]},
            )
            pending_human = None
```

Save file may also store `summary` field from `chain.memory.buffer` for inspection — see [[chat-session-memory-persist-json]].

## peek / buffer size

`chain.memory.buffer` for summary holds the **compressed** text — compare char count to buffer mode after a long REPL to see token savings.

## See also

- [[langchain-memory-types-overview]]
- [[conversation-buffer-memory]]
- [[chat-session-memory-persist-json]]
- [[langchain-remember-me-chat-repl]]