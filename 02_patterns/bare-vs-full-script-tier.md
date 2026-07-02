---
title: Bare vs Full Script Tier
tags:
  - pattern
  - python
  - software-engineering
  - teaching
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-remember-me-chat-repl]]"
  - "[[ingest-cli-parser-and-handlers]]"
  - "[[python-argparse-cli]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03 bare + full py pair (learning)
---

# Bare vs Full Script Tier

Two files for one capstone: **`_bare.py`** (minimum spine) and **full `.py`** (CLI, persist, stretch). Learners master core behavior first; features accumulate without deleting the teaching path.

**Layman:** bicycle with training wheels file — same ride, fewer parts to read.

## Capstone 03 example

| File | Keeps | Strips |
|------|-------|--------|
| `capstone_03_remember_me_chat_bare.py` | path, LLM, `CAPSTONE_PROMPT`, chain, REPL | argparse, save/load, summary, demos |
| `capstone_03_remember_me_chat.py` | everything | — |

Bare docstring points to full version — one direction of truth.

## What belongs in bare

- Imports + `sys.path` bootstrap
- Constants (`CHAT_LLM_PARAMS`, prompt)
- `build_chain()` / one happy path
- `main()` minimal loop

## What belongs in full only

- `argparse` modes ([[python-argparse-cli]])
- JSON persist ([[chat-session-memory-persist-json]])
- Alternate memory types ([[conversation-summary-memory]])
- Scripted demos ([[scripted-multi-turn-chat-demos]])
- `finish_session` hooks (peek/save on exit)

## kb capture rule

Distill **generic patterns** into kb once; bare and full both link to the same notes. Do not duplicate two vault notes per file — tier difference is **scope**, not separate concepts.

## See also

- [[langchain-remember-me-chat-repl]]
- [[python-project-root-for-imports]]