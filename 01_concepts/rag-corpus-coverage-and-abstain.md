---
title: RAG Corpus Coverage and LLM Abstain
tags:
  - rag
  - retrieval
  - llm
  - prompts
topics:
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-troubleshooting-retrieval-first]]"
  - "[[corpus-batch-ingest]]"
  - "[[incremental-rag-web-ingest]]"
  - "[[retrievalqa-chain-type-packing]]"
  - "[[rag-moc]]"
source: Distilled from capstone chat prompt design (learning)
---

# RAG Corpus Coverage and LLM Abstain

A correct RAG answer needs **two layers**: retrieval (what chunks exist) and generation (what the LLM says). **“Not covered”** can mean **no relevant source in the index** or **sources exist but the LLM refuses to invent** — different problems.

**Layman:** the librarian may hand you cards (retriever always returns **k**), but the writer may say *“nothing here answers that”* (abstain).

## Two meanings of “not covered”

| Case | Retriever | LLM behavior | Example |
|------|-----------|--------------|---------|
| **Corpus gap** | Hits are off-topic or thin | Abstain or hallucinate risk | Ask about **agents** before ingesting agent docs |
| **Soft abstain** | Hits exist but don’t support answer | Prompt says decline | Ask **France capital** in a ML-paper index |

Retriever **always returns k chunks** (unless store is empty). Abstain is an **LLM + prompt** choice at invoke time.

## Corpus scope honesty

Catalog what the index is **for** vs **not for**:

```json
"honest_scope": {
  "good_for": ["RAG theory", "retrieval pipeline"],
  "not_enough_for": ["Full API reference", "every framework topic"]
}
```

PDF tier may cover RAG papers; **web/HTML ingest** fills API gaps (agents, loaders) — see [[incremental-rag-web-ingest]].

## Prompt-level abstain (chat pattern)

Instruct the model to use **only** context that helps, and to say briefly when indexed material does not answer:

```text
If none of the passages help answer the question, say that the indexed
sources do not cover it.
```

Also guard against **example Q&A tables** inside papers — do not echo benchmark questions as if they were user questions.

## Debugging

1. [[debug-retrieval-without-llm]] — are hits on-topic?
2. If hits good but answer abstains → prompt / temperature / model
3. If hits bad → corpus gap or [[watsonx-truncate-input-tokens-rag-trap]]

## See also

- [[rag-troubleshooting-retrieval-first]]
- [[rag-llm-size-vs-retrieval-quality]]
- [[rag-moc]]