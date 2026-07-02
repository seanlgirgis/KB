---
title: kb Home
tags:
  - moc
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[rag-moc]]"
  - "[[python-moc]]"
  - "[[software-engineering-moc]]"
---

# kb Home

Entry point for Sean's personal knowledge vault. Designed to scale to **thousands of notes** — you navigate from here and search, not by scrolling folders.

## Domain maps (start here)

- [[rag-moc]] — RAG, embeddings, retrieval, ingest, chat, LangChain chains
- [[python-moc]] — stdlib, CLI, I/O patterns
- [[software-engineering-moc]] — cross-cutting patterns and architecture

**LangChain LCEL:** [[langchain-lcel-build-sequence]] · **Classic chains** (`LLMChain`, `SequentialChain`): [[langchain-classic-chains-overview]]

**Agents & ReAct:** [[langchain-agent-patterns-overview]] (index) · [[langchain-react-agent-loop]]

**RAG/agents as HTTP:** [[agentic-rag-web-service-stack]]

**RAG frameworks (chunk/embed/split):** [[rag-framework-ecosystem-comparison]] · [[rag-pipeline-tool-stages]]

More domains (e.g. databases/SQL) get a MOC under this hub when study starts — not a new vault.

## How to find things

| You want… | Do this |
|-----------|---------|
| A subject area | Open a domain MOC above |
| A specific topic | Obsidian search: `file:rag-`, `tag:python`, or title keywords |
| “What do we have on X?” | Ask Grok Build (kb agent) — audit + links |
| Fuzzy recall (later) | Vault RAG after embed pipeline exists |

See `docs/VAULT_MODEL.md` — **Search and navigation**, **Scale expectation**.

## Workflow

1. Capture in `00_inbox/` or ask Grok Build to create a note
2. Curate into type folder (`01_concepts/`, `02_patterns/`, …)
3. Link from the **domain MOC** (and cross-link if multi-domain)

## Agent docs

- `BOOTSTRAP.md` — Grok session rules
- `docs/NOTE_CONVENTIONS.md` — note format
- `docs/VAULT_MODEL.md` — scale, MOC hierarchy, when to add subfolders