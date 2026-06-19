---
title: Watsonx TRUNCATE_INPUT_TOKENS RAG Trap
tags:
  - rag
  - embeddings
  - watsonx
  - troubleshooting
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-ingest-query-settings-parity]]"
  - "[[rag-troubleshooting-retrieval-first]]"
  - "[[chroma-stores-vectors-text-metadata]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source: Distilled from capstone embedding debug (learning)
---

# Watsonx TRUNCATE_INPUT_TOKENS RAG Trap

IBM Watsonx embedding params can include **`TRUNCATE_INPUT_TOKENS`** — a limit on how many tokens get embedded. Course labs often set **`3`** for tiny demos. In a real RAG index that setting **destroys semantic search**: almost every query and chunk collapses to the same tiny prefix, so Chroma returns arbitrary or identical hits regardless of question wording.

**Layman:** you labeled every index card using only the **first three letters** of the title — every search looks the same.

## What went wrong

Typical lab pattern (fine for a 5-line demo, **wrong for capstone**):

```python
EMBED_PARAMS = {
    EmbedTextParamsMetaNames.TRUNCATE_INPUT_TOKENS: 3,
    EmbedTextParamsMetaNames.RETURN_OPTIONS: {"input_text": True},
}
```

**Symptoms:**

- Different questions retrieve the **same top-k** chunks
- `debug_retrieval` cosine between two unrelated questions **> 0.99**
- Chat answers feel random or ignore the question
- **Stored chunk text** in Chroma may still look full-length — the bug is in **vectors**, not `page_content`

## Fix

1. **Remove** `TRUNCATE_INPUT_TOKENS` from shared `EMBED_PARAMS` (or set to a value that covers full chunks).
2. Use the **same** `EMBED_PARAMS` in **ingest and chat**.
3. **Re-embed everything:** manifest skip is by **PDF hash**, not embed params — run **`--force`** (or delete collection) after changing embed settings.

```python
# Capstone-style fix — full-text embedding signal
EMBED_PARAMS = {
    EmbedTextParamsMetaNames.RETURN_OPTIONS: {"input_text": True},
}
```

## Why `--force` is required

| Change | Manifest hash | Action |
|--------|---------------|--------|
| Same PDF bytes | Unchanged | Normal skip |
| **Embed params changed** | Still unchanged | **Must `--force`** — old vectors are wrong |

See [[chroma-persist-append-and-reingest]] and [[rag-ingest-query-settings-parity]].

## How to verify

1. Run retriever-only debug — [[debug-retrieval-without-llm]]
2. Ask two **different** questions — hits should **not** be identical
3. Optional cosine compare on query embeddings — warn if > 0.99

## See also

- [[rag-troubleshooting-retrieval-first]]
- [[chroma-stores-vectors-text-metadata]]
- [[rag-moc]]