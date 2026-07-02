---
title: Scripted Multi-Turn Chat Demos
tags:
  - pattern
  - langchain
  - memory
  - testing
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-remember-me-chat-repl]]"
  - "[[seed-chat-message-history]]"
  - "[[conversation-buffer-memory]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03 demo_little_cat / demo_alice (learning)
---

# Scripted Multi-Turn Chat Demos

Automated **multi-turn** runs without `input()` — prove memory works before interactive REPL. Capstone 03: `--demo cat` and `--demo alice` via a shared **`run_scripted_turns`** helper.

**Layman:** play a recorded conversation to test the assistant’s notepad.

## Helper

```python
def run_scripted_turns(chain, inputs: list[str], *, title: str) -> None:
    print(f"\n=== {title} ===")
    for i, user_input in enumerate(inputs, start=1):
        print(f"\n--- Turn {i} ---")
        print(f"You: {user_input}")
        reply = chat_once(chain, user_input)
        print(f"AI: {reply}")
    print(f"\n=== End: {title} ===")
```

One **`ConversationChain`** for all turns — same rule as REPL: build once.

## Little cat demo (identity recall)

```python
run_scripted_turns(
    chain,
    [
        "Hello, I am a little cat. Who are you?",
        "What can you do?",
        "Who am I?",  # expects little cat / cat identity
    ],
    title="Little cat demo",
)
```

Turn 3 is the **memory proof** — no seed; identity must come from turn 1 buffer.

## Alice demo (seeded + recall)

Build chain with [[seed-chat-message-history]], then scripted color/hiking/name questions. `demo_alice` **returns** the chain so `finish_session` can peek/save.

## After demos

Demos default **`peek=True`** on exit — always show `chain.memory.buffer` unless user disables peek. Wire:

```python
finish_session(chain, peek=args.peek or True, save=args.save)
```

## CLI exclusivity

`--demo` is **mutually exclusive** with REPL and `-q` — one session mode per run. See [[langchain-remember-me-chat-repl]].

## See also

- [[seed-chat-message-history]]
- [[langchain-remember-me-chat-repl]]
- [[conversation-buffer-memory]]