---
title: Cosine Similarity in Vector Retrieval
tags:
  - rag
  - retrieval
  - embeddings
  - math
topics:
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[retrieval-ranking-pipeline]]"
  - "[[dense-passage-retrieval-dpr]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[watsonx-truncate-input-tokens-rag-trap]]"
  - "[[chroma-stores-vectors-text-metadata]]"
  - "[[rag-moc]]"
source: Distilled from Chroma retrieval + debug_retrieval cosine compare
---

# Cosine Similarity in Vector Retrieval

**Cosine similarity** measures how aligned two embedding vectors are — same direction in high-dimensional space means similar meaning. Chroma uses it (or equivalent distance) to rank every stored chunk against your question vector.

**Layman:** two arrows. Point the same way → high score → good match. Not keyword counting.

## Score intuition

| Cosine | Meaning |
|--------|---------|
| **≈ 1.0** | Almost same direction — very similar |
| **≈ 0.0** | Unrelated |
| **≈ -1.0** | Opposite (rare in practice for text embeddings) |

Higher cosine → chunk rises toward the top of the candidate list (your capstone: top **20** before MMR).

## What Chroma does at query time

```text
1. embed_query("What is DPR?")     → query vector
2. Compare to every chunk vector   → cosine (or distance derived from it)
3. Rank all chunks                 → highest scores → fetch_k pool (20)
4. (If MMR) re-rank pool           → final k (5)   → see [[rag-mmr-retriever]]
```

Not keyword search. No counting how often “RAG” appears — **geometry of the numbers**.

## Toy demo (no Chroma, no embedder)

Purpose: see “similar topics → high cosine; unrelated → low” with **numbers**, not abstract arrows. Pretend 3-dim vectors stand in for real 384+ dim embeddings.

```python
import math

def cosine(a, b):
    dot = sum(x * y for x, y in zip(a, b))
    return dot / (math.sqrt(sum(x * x for x in a)) * math.sqrt(sum(x * x for x in b)))

# tiny fake embedding vectors (3 dimensions)
v_rag = [0.9, 0.1, 0.0]
v_dpr = [0.8, 0.2, 0.1]
v_france = [0.0, 0.1, 0.9]

print(cosine(v_rag, v_dpr))     # high → similar topics
print(cosine(v_rag, v_france))  # low → different topics
```

Same formula at scale when Chroma ranks hundreds of chunks.

## Real demo (Watsonx query vectors)

Same math as [[debug-retrieval-without-llm]] `compare_query_vectors`:

```python
import math

def cosine(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(x * x for x in b))
    return 0.0 if na == 0 or nb == 0 else dot / (na * nb)

v1 = embed.embed_query("What is RAG?")
v2 = embed.embed_query("What is retrieval augmented generation?")
print(cosine(v1, v2))  # high if embeddings capture paraphrase
```

We used this for real when **truncate=3** made totally different questions print cosine **≈ 1.0** — see [[watsonx-truncate-input-tokens-rag-trap]].

## Broken retrieval signal

If **different questions** produce cosine **≈ 1.0** between their query vectors, ranking is meaningless — you will see identical hits for unrelated queries. Classic cause: [[watsonx-truncate-input-tokens-rag-trap]] (`TRUNCATE_INPUT_TOKENS: 3`).

Fix embed params → `--force` re-ingest → re-run debug script.

## Vectors vs text you read

Chroma stores **vectors** for search and **page_content** for display. Cosine operates on vectors; the LLM reads `page_content`. See [[chroma-stores-vectors-text-metadata]].

## See also

- [[retrieval-ranking-pipeline]]
- [[dense-passage-retrieval-dpr]]
- [[debug-retrieval-without-llm]]
- [[rag-moc]]