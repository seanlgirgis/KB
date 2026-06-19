---
title: RAG Chat CLI and REPL Loop
tags:
  - pattern
  - rag
  - cli
  - python
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[ingest-cli-parser-and-handlers]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-ingest-chat-two-script-architecture]]"
  - "[[python-argparse-cli]]"
  - "[[rag-moc]]"
source: Distilled from chat script CLI pattern (learning capstone)
---

# RAG Chat CLI and REPL Loop

Chat script UX: **one-shot** question from `sys.argv` for scripts and demos; **REPL loop** from `input()` for interactive study. Build the `RetrievalQA` chain once; reuse for every question.

## Pattern

```python
def ask(qa, question: str) -> str:
    result = qa.invoke(question)
    if isinstance(result, dict):
        return str(result.get("result", result)).strip()
    return str(result).strip()


def main() -> None:
    require_chroma_data()
    qa = build_qa_chain(load_vector_store())

    if len(sys.argv) > 1:
        question = " ".join(sys.argv[1:]).strip()
        print(ask(qa, question))
        return

    print("RAG chat ('quit' to exit)")
    while True:
        question = input("Q: ").strip()
        if not question or question.lower() in ("quit", "exit"):
            break
        print(ask(qa, question))
        print()
```

## Design choices

| Choice | Rationale |
|--------|-----------|
| `join(sys.argv[1:])` | Multi-word questions without quoting fights on Windows |
| Parse `result` dict | `RetrievalQA.invoke` returns `{"query", "result"}` |
| Chain built once | Avoid reloading Chroma / LLM per question |
| Guard before chain | [[rag-shared-config-module]] `chroma_has_data()` |

## vs ingest CLI

| | Ingest | Chat |
|--|--------|------|
| Modes | `--list`, `--corpus`, `--web`, positional source | argv question or REPL |
| Shared | [[ingest-cli-parser-and-handlers]] patterns | Simpler — often no argparse |

## See also

- [[rag-ingest-chat-two-script-architecture]]
- [[debug-retrieval-without-llm]] — run before tuning chat
- [[rag-moc]]