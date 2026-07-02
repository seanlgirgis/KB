---
title: Chat Session Memory Persist to JSON
tags:
  - pattern
  - langchain
  - memory
  - json
  - python
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[conversation-buffer-memory]]"
  - "[[langchain-memory-types-overview]]"
  - "[[python-json-read-write-files]]"
  - "[[conversation-summary-memory]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03_remember_me_chat.py --save/--load (learning)
---

# Chat Session Memory Persist to JSON

**Buffer memory** is RAM-only by default — **quit = gone**. Optional **`--save` / `--load`** writes chat turns to **JSON on disk** so a **new process** can restore the session. Still **not** Chroma: no embeddings, no retrieval — just serialized messages (and optional summary text).

**Layman:** photocopy the notepad at end of call; next call, tape it back on the desk.

## RAM vs JSON vs Chroma

| | Buffer RAM | `--save` JSON | Chroma (Capstone 01) |
|--|------------|---------------|----------------------|
| **What** | Live transcript string | `messages[]` on disk | Chunk vectors + text |
| **Survives quit** | No | Yes (if saved) | Yes |
| **Search** | Full history in prompt | Reload into memory | Cosine / MMR |
| **Use case** | Same REPL session | Resume chat tomorrow | Ask over documents |

## Save file shape

```json
{
  "version": 1,
  "memory_type": "buffer",
  "messages": [
    {"role": "human", "content": "My name is Sean."},
    {"role": "ai", "content": "Hi Sean!"}
  ],
  "summary": null
}
```

For `summary` memory, `summary` may hold compressed buffer string; `memory_type` records which class to rebuild.

## Serialize messages from chain

```python
def messages_to_serializable(messages: list[BaseMessage]) -> list[dict[str, str]]:
    return [{"role": message_role(m), "content": m.content} for m in messages]

def save_memory(chain: ConversationChain, path: Path) -> None:
    rows = messages_to_serializable(get_chat_messages(chain))
    payload = {
        "version": 1,
        "memory_type": memory_type_of(chain),
        "messages": rows,
        "summary": chain.memory.buffer if is_summary else None,
    }
    with path.open("w", encoding="utf-8") as fh:
        json.dump(payload, fh, indent=2)
```

```python
def get_chat_messages(chain) -> list[BaseMessage]:
    chat_memory = getattr(chain.memory, "chat_memory", None)
    return list(chat_memory.messages) if chat_memory else []

def message_role(message: BaseMessage) -> str:
    if isinstance(message, HumanMessage):
        return "human"
    if isinstance(message, AIMessage):
        return "ai"
    return message.type
```

## Load into new chain

```python
def history_from_serializable(rows: list[dict]) -> ChatMessageHistory:
    history = ChatMessageHistory()
    for row in rows:
        history.add_message(message_from_role(row["role"], row["content"]))
    return history

chain = build_conversation_chain(
    memory_type=saved_type,
    chat_memory=history_from_serializable(rows),
)
```

**Load rule:** if JSON has `memory_type`, it **wins** over CLI `--memory` — print a note when they disagree.

## Summary memory replay

`ConversationSummaryMemory` may need **`replay_summary_from_messages`** after load — walk human/ai pairs and call `save_context` so internal summary state matches messages.

## CLI wiring

```text
--save [PATH]     write on exit (default data/chat_memory.json)
--load PATH       build chain from file before REPL / -q
-q "Who am I?"    one-shot after --load proves cross-process recall
```

Call `finish_session(chain, peek=..., save=...)` after REPL, demo, or one-shot.

## See also

- [[python-json-read-write-files]]
- [[conversation-buffer-memory]]
- [[langchain-memory-types-overview]]
- [[langchain-remember-me-chat-repl]]