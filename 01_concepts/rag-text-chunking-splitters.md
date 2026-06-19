---
title: RAG Text Chunking and Splitters
tags:
  - rag
  - chunking
  - langchain
  - text-splitting
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[langchain-documents-and-loaders]]"
  - "[[rag-ingest-query-settings-parity]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-moc]]"
source:
---

# RAG Text Chunking and Splitters

LLMs and embedding APIs have **limited context**. Long documents must be cut into **chunks** — smaller text segments that each become one vector in search. A **text splitter** decides *where* to cut and how much overlap to keep between neighbors so answers do not lose sentences split in half.

**Layman analogy:** a long article is chopped into index cards. Each card fits in the search drawer (embedding limit). Slight overlap between cards so a sentence is not cut off at the edge with no context on the next card.

## Core idea

| Knob | Role |
|------|------|
| `chunk_size` | Target max characters (or tokens) per chunk |
| `chunk_overlap` | Characters repeated at chunk boundaries |
| `separators` | Prefer splitting on paragraph → line → sentence → space |

Smaller chunks = precise retrieval, less context per hit. Larger chunks = more context, blurrier match.

## RecursiveCharacterTextSplitter

Common LangChain splitter — tries separators **in order**, recursively splitting oversized pieces.

```python
from langchain_text_splitters import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50,
    separators=["\n\n", "\n", ". ", " ", ""],
)

chunks = splitter.split_documents(documents)  # list of Document
```

**Separator priority:** blank line (new section) before single newline before sentence before word — keeps semantic boundaries when possible.

## Choosing chunk_size and chunk_overlap

**Starting point (character-based):** `500` / `50` overlap — reasonable for prose PDFs and early prototypes.

| Situation | Guidance |
|-----------|------------|
| Dense technical docs | Slightly larger chunks (800–1200) if embeddings allow |
| FAQ / short pages | Smaller chunks; overlap ~10% of size |
| Code-heavy text | Consider language-aware splitters later |
| Same store for ingest + chat | **Use identical numbers** in both scripts |

**Overlap rule of thumb:** ~10% of `chunk_size` — enough to bridge boundary sentences, not so much you duplicate half the doc.

Store chosen values in the **manifest** (see [[ingest-manifest-schema-and-fields]]) so you know what settings built the index.

## When to use character splitting

- PDFs, markdown, plain text ingest pipelines
- Quick RAG labs before investing in token-aware splitters

## When not to use

- Structured JSON/CSV — split by record, not character
- Code repositories — use AST or language splitters
- Very large single files — combine with streaming loaders

## Usage notes

- Split **after** load — loader produces `Document`s; splitter consumes them.
- Chunk count affects embed cost linearly — dedupe at manifest layer saves money.
- Changing `chunk_size` without re-embed changes retrieval — treat as index schema change; use `--force` re-ingest.

## See also

- [[langchain-documents-and-loaders]] — what gets split
- [[tag-chunks-with-source-metadata]] — after split
- [[rag-ingest-query-settings-parity]] — match ingest and chat
- [[rag-moc]]