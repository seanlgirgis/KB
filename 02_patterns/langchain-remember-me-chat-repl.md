---
title: LangChain Remember-Me Chat REPL
tags:
  - pattern
  - langchain
  - memory
  - chat
  - cli
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[bare-vs-full-script-tier]]"
  - "[[scripted-multi-turn-chat-demos]]"
  - "[[seed-chat-message-history]]"
  - "[[suppress-langchain-classic-deprecation-warnings]]"
  - "[[conversation-summary-memory]]"
  - "[[conversation-buffer-memory]]"
  - "[[langchain-memory-types-overview]]"
  - "[[chat-session-memory-persist-json]]"
  - "[[capstone-rag-vs-session-memory]]"
  - "[[rag-chat-cli-repl]]"
  - "[[python-project-root-for-imports]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03 py + capstone03.md (learning)
---

# LangChain Remember-Me Chat REPL

**Capstone 03:** `ConversationChain` + memory + `CAPSTONE_PROMPT` + REPL. Two script tiers:

| Script tier | Contents |
|-------------|----------|
| **Bare** (bites 1–5) | Buffer only, no argparse — teaching spine |
| **Full** | `--memory`, `--save`/`--load`, `--demo`, `-q`, `--peek` |

Tier rationale: [[bare-vs-full-script-tier]]. No Chroma. See [[capstone-rag-vs-session-memory]].

## Bare spine (minimum)

```python
def build_chain() -> ConversationChain:
    return ConversationChain(
        llm=make_watsonx_llm(CHAT_LLM_PARAMS),
        memory=ConversationBufferMemory(),
        prompt=CAPSTONE_PROMPT,
        verbose=False,
    )

chain = build_chain()  # once, before loop
```

`chain.invoke(input=user_text)` — key is **`input`**, not `question`. Parse `result["response"]`.

## Custom prompt (memory hygiene)

Default prompts cause run-on replies and fake `Human:` lines that **pollute the buffer**:

```python
CAPSTONE_PROMPT = PromptTemplate(
    input_variables=["history", "input"],
    template="""You are a helpful assistant in a multi-turn chat.

Rules:
- Reply with ONE short assistant message only.
- Do NOT write "Human:" or pretend the user said something else.
- Do NOT continue the conversation for the user.
- Remember facts the user stated earlier in this chat.

Current conversation:
{history}

Human: {input}
AI:""",
)
```

| Before | After |
|--------|-------|
| Talkative default | One short reply |
| Junk in buffer | Clean recall on turn 2 |
| `verbose=True` | `verbose=False` |

## Full CLI modes (mutually exclusive)

| Mode | Flag | Behavior |
|------|------|----------|
| REPL | (default) | `input()` until quit |
| Demo cat | `--demo cat` | Three scripted turns → “Who am I?” |
| Demo Alice | `--demo alice` | Seeded `ChatMessageHistory` + recall name/color |
| One-shot | `-q "..."` | Single turn; use with `--load` for cross-process recall |

Plus: `--memory buffer|summary`, `--save [PATH]`, `--load PATH`, `--peek` on exit. Demos default to peek.

```python
mode = parser.add_mutually_exclusive_group()
mode.add_argument("--demo", choices=["cat", "alice"])
mode.add_argument("-q", "--question", metavar="TEXT")
parser.add_argument("--save", type=Path, nargs="?", const=DEFAULT_MEMORY_PATH)
```

Details: [[chat-session-memory-persist-json]], [[conversation-summary-memory]], [[scripted-multi-turn-chat-demos]].

## build_memory factory

```python
def build_memory(memory_type: str, *, chat_memory: ChatMessageHistory | None = None):
    llm = make_chat_llm()
    if memory_type == "summary":
        return ConversationSummaryMemory(llm=llm, chat_memory=chat_memory)
    return ConversationBufferMemory(chat_memory=chat_memory)
```

Alice / cat demos: [[seed-chat-message-history]], [[scripted-multi-turn-chat-demos]].

## Session teardown

```python
def finish_session(chain, *, peek: bool, save: Path | None) -> None:
    if peek:
        peek_memory(chain)
    if save is not None:
        save_memory(chain, save)
```

Call after REPL, `-q`, or `--demo` — centralizes exit hooks.

## peek_memory (bite 8)

```python
def peek_memory(chain: ConversationChain) -> None:
    print(chain.memory.buffer)
    print(f"Buffer size (chars): {len(chain.memory.buffer)}")
```

Inspect after demos or when recall fails — see what the chain actually stored.

## Manual test script (REPL)

| Turn | You type | Expect |
|------|----------|--------|
| 1 | `My name is Sean.` | Acknowledges |
| 2 | `What's my name?` | **Sean** |
| 3 | `My favorite color is blue.` | Acknowledges |
| 6 | `What was my favorite color again?` | **blue** |

## Traps

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ImportError` on memory | Wrong package | `langchain_classic.memory` |
| Forgets name turn 2 | No memory on chain | `memory=ConversationBufferMemory()` |
| Resets each loop | New chain inside `while` | Build **once** before loop |
| `invoke` key error | Wrong kwarg | `input=` for `ConversationChain` |
| Expects doc answers | Wrong capstone | Use RAG chat for corpus |
| Run-on / fake Human | Default prompt | `CAPSTONE_PROMPT` |
| Slow after many turns | Buffer growth | [[conversation-summary-memory]] |
| Summary empty on turn 1 | No history to compress | Chat first or `--load` |
| Load type mismatch | JSON `memory_type` wins CLI | Re-save or accept file type |

## Imports and path

- `ConversationChain`, memories, `PromptTemplate` → **`langchain_classic`**
- `ChatMessageHistory` → `langchain_community.chat_message_histories`
- `HumanMessage`, `AIMessage` → `langchain_core.messages` (save/load)
- `watson_llm` parent folder → [[python-project-root-for-imports]]
- **Not** `capstone_shared.py` for core 03 — RAG-only

Deprecation filter: [[suppress-langchain-classic-deprecation-warnings]].

## See also

- [[conversation-buffer-memory]]
- [[capstone-rag-vs-session-memory]]
- [[rag-chat-cli-repl]]
- [[langchain-rag-chains-overview]]
- [[rag-moc]]