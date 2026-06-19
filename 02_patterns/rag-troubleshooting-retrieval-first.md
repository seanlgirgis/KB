---
title: RAG Troubleshooting — Retrieval First
tags:
  - pattern
  - rag
  - troubleshooting
  - debugging
topics:
  - retrieval
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[debug-retrieval-without-llm]]"
  - "[[watsonx-truncate-input-tokens-rag-trap]]"
  - "[[rag-ingest-query-settings-parity]]"
  - "[[rag-corpus-coverage-and-abstain]]"
  - "[[rag-moc]]"
source: Distilled from capstone debug workflow (learning)
---

# RAG Troubleshooting — Retrieval First

When chat answers are wrong, empty, or nonsensical, **check retrieval before blaming the LLM or prompt**. If the wrong chunks arrive, no prompt fix will save you.

**Layman:** if the librarian hands you the wrong index cards, yelling at the writer won’t help — fix the card pull first.

## Decision flow

```text
Bad answer?
  1. Run retriever-only debug (no LLM)
  2. Do top-k chunks match the question topic?
       NO  → embedding params, ingest parity, corpus gap, k/MMR
       YES → prompt, abstain rules, LLM size/temperature
  3. Two different questions → same hits?
       YES → likely embed trap (truncate) or broken index
  4. Fixed EMBED_PARAMS?
       → --force full re-ingest, re-test chat
```

## Step 1 — Retriever only (debugger script)

Run a **standalone** `debug_retrieval.py`-style script — see [[debug-retrieval-without-llm]] for the full pattern (print hits, optional cosine compare, argv + REPL).

Use the **same** `search_type` and `search_kwargs` as chat (e.g. MMR, `k=5`, `fetch_k=20`).

Ask: *Would a human say these previews answer the question?*

**Tip:** two different questions with **identical** hit lists → retrieval broken before you touch the LLM.

## Step 2 — Same top-k for different questions?

If unrelated questions return **identical** hit lists or previews:

- Check [[watsonx-truncate-input-tokens-rag-trap]]
- Confirm ingest and chat share [[rag-ingest-query-settings-parity]]

Optional: cosine similarity on `embed_query(q1)` vs `embed_query(q2)` — near 1.0 on different text = smoking gun.

## Step 3 — Hits on-topic but answer still bad?

Retriever OK → tune **LLM layer**:

- Prompt rules (ignore example Q&A tables in papers)
- [[rag-corpus-coverage-and-abstain]] — “not covered” vs soft reject
- [[rag-llm-size-vs-retrieval-quality]] — small model + noisy context

## Step 4 — Fix embed params → re-ingest

Changing `EMBED_PARAMS` requires **`--force`** re-embed even when PDF hashes unchanged.

## Habit

**Every RAG bug session:** `debug_retrieval` first, `chat` second.

## See also

- [[debug-retrieval-without-llm]]
- [[watsonx-truncate-input-tokens-rag-trap]]
- [[rag-moc]]