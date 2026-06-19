---
title: RAG Query Rewrite for Typos
tags:
  - pattern
  - rag
  - llm
  - retrieval
topics:
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-troubleshooting-retrieval-first]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-moc]]"
source:
---

# RAG Query Rewrite for Typos

Misspelled or sloppy queries embed poorly and retrieve weak chunks. A **two-step** pattern: **LLM #1** rewrites the user question (fix spelling, keep domain); **retriever + LLM #2** answers from chunks using the cleaned query.

**Layman:** secretary fixes your handwritten note before the librarian searches.

## When to use

- User-facing chat with typos or speech-to-text
- Domain terms that must stay precise (`retrieval augmented generation` not drift to unrelated topics)

## When not to use

- Retrieval already healthy on raw queries
- Extra latency/cost unacceptable — try simpler embed models or hybrid search first

## Pattern (illustrative)

```python
REWRITE_PROMPT = """Fix spelling and grammar. Keep the same topic and intent.
Do not add new subjects. Output only the rewritten question.

Question: {question}
Rewritten:"""

def rewrite_question(llm, question: str) -> str:
    return llm.invoke(REWRITE_PROMPT.format(question=question)).strip()


def answer_with_rewrite(qa_chain, rewrite_llm, question: str) -> str:
    cleaned = rewrite_question(rewrite_llm, question)
    return qa_chain.invoke(cleaned)
```

## Guardrails

- **Scope lock** — “do not add topics” prevents rewrite from becoming a new question
- **Debug both** — [[debug-retrieval-without-llm]] on raw vs rewritten query; compare hits
- **Do not rewrite** if retrieval-first debug shows embed trap — fix [[watsonx-truncate-input-tokens-rag-trap]] first

## Tradeoffs

| Pro | Con |
|-----|-----|
| Better embed match on typos | Two LLM calls (rewrite + answer) |
| Keeps user phrasing intent | Rewrite model can drift if prompt weak |

## See also

- [[rag-troubleshooting-retrieval-first]]
- [[rag-corpus-coverage-and-abstain]]
- [[rag-moc]]