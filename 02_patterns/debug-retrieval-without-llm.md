---
title: Debug Retrieval Without the LLM
tags:
  - pattern
  - rag
  - debugging
  - chromadb
  - tooling
topics:
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-troubleshooting-retrieval-first]]"
  - "[[watsonx-truncate-input-tokens-rag-trap]]"
  - "[[chroma-stores-vectors-text-metadata]]"
  - "[[pluggable-embedding-models]]"
  - "[[cosine-similarity-vector-retrieval]]"
  - "[[retrieval-ranking-pipeline]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from retrieval debugger script pattern (learning capstone)
---

# Debug Retrieval Without the LLM

Keep a **standalone retriever debug script** beside your chat script. It prints which chunks Chroma returns for a question — **no LLM**, no answer generation cost. This is the highest-leverage habit in [[rag-troubleshooting-retrieval-first]]: prove search works before tuning prompts or swapping models.

**Layman:** ask the librarian to slide index cards across the desk — the writer stays in another room.

## Why a separate script

| Chat script | Debug script |
|-------------|--------------|
| Retriever + LLM + prompt | **Retriever only** |
| Hard to see which chunks drove the answer | Prints **source, page, text preview** per hit |
| Expensive to iterate | Fast loop on questions |

Same shared config as chat: `load_vector_store()`, `make_embedding_model()`, **identical** `search_type` / `search_kwargs`.

## Match chat retriever exactly

```python
# Constants at top — must mirror production chat
SEARCH_TYPE = "mmr"
SEARCH_KWARGS = {"k": 5, "fetch_k": 20}
PREVIEW_CHARS = 350
```

If debug uses `k=3` but chat uses MMR `k=5`, you debug the **wrong** behavior.

## Core flow

```text
require_chroma()           # friendly exit if no ingest
retriever = build_retriever(load_vector_store())
docs = retriever.invoke(question)
print_hits(question, docs) # human-readable chunk list
optional: compare_query_vectors(q1, q2)  # embed trap detector
```

## Example — full debugger pattern

Generic names; wire your shared module paths.

```python
import math
import sys

SEARCH_TYPE = "mmr"
SEARCH_KWARGS = {"k": 5, "fetch_k": 20}
PREVIEW_CHARS = 350


def require_chroma() -> None:
    if chroma_has_data():
        return
    print("No vector store. Run ingest first.")
    sys.exit(1)


def short_source(source_id: str) -> str:
    return source_id.rsplit("/", 1)[-1] if source_id else "?"


def build_retriever(vector_store):
    return vector_store.as_retriever(
        search_type=SEARCH_TYPE,
        search_kwargs=SEARCH_KWARGS,
    )


def cosine(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(x * x for x in b))
    return 0.0 if na == 0 or nb == 0 else dot / (na * nb)


def print_hits(question: str, docs: list) -> None:
    print(f"Q: {question}")
    print(f"  retriever: {SEARCH_TYPE}  {SEARCH_KWARGS}")
    print(f"  hits: {len(docs)}")
    for i, doc in enumerate(docs, start=1):
        meta = doc.metadata
        src = short_source(meta.get("ingest_source_id", meta.get("source", "?")))
        page = meta.get("page", "?")
        preview = doc.page_content[:PREVIEW_CHARS].replace("\n", " ")
        if len(doc.page_content) > PREVIEW_CHARS:
            preview += "..."
        print(f"  [{i}] {src}  p{page}")
        print(f"      {preview}")


def compare_query_vectors(q1: str, q2: str) -> None:
    embed = make_embedding_model()
    v1 = embed.embed_query(q1)
    v2 = embed.embed_query(q2)
    sim = cosine(v1, v2)
    print(f"cosine({q1!r}, {q2!r}) = {sim:.4f}")
    if sim > 0.99:
        print("  warning: vectors nearly identical — check EMBED_PARAMS (truncate?)")


def debug_question(question: str, *, compare_to: str | None = None) -> None:
    retriever = build_retriever(load_vector_store())
    docs = retriever.invoke(question)
    print()
    print_hits(question, docs)
    if compare_to:
        print()
        compare_query_vectors(question, compare_to)
    print()
```

## How to run

**One-shot** (CI, quick check):

```text
python debug_retrieval.py "What is the lost in the middle problem?"
```

**REPL loop** (interactive tuning):

```text
python debug_retrieval.py
Q: What is RAG?
Compare cosine to (optional): What is retrieval augmented generation?
```

**Tip printed to user:** if **two different questions** return **identical hits**, retrieval is suspect — see [[watsonx-truncate-input-tokens-rag-trap]].

## How to read output

| Line | Meaning |
|------|---------|
| `hits: 5` | Retriever returned k documents (after MMR) |
| `[1] paper.pdf p3` | Source filename + PDF page from metadata |
| Preview text | [[chroma-stores-vectors-text-metadata]] `page_content` — what LLM would see |
| `cosine ≈ 1.0` on different questions | Broken query embeddings |

## When hits look wrong

| Symptom | Likely cause |
|---------|----------------|
| Same hits for unrelated questions | Truncate embed trap |
| Off-topic previews | Corpus gap or need `--web` ingest |
| Too many duplicate previews | Tune MMR / lower k |
| Zero hits | Empty store or wrong `CHROMA_DIR` |

## What this script does not do

- No `RetrievalQA`, no `make_watsonx_llm()` — by design
- No manifest reads — Chroma only
- Does not fix bugs — **shows** them so you fix ingest, embed params, or corpus

## Habit

```text
New RAG bug  →  debug_retrieval.py  →  then chat
Changed k/MMR/embed params  →  debug first
Before prompt surgery  →  debug first
```

## See also

- [[rag-troubleshooting-retrieval-first]] — parent workflow
- [[watsonx-truncate-input-tokens-rag-trap]]
- [[chroma-stores-vectors-text-metadata]]
- [[rag-moc]]