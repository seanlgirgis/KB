---
title: Incremental RAG Web Ingest
tags:
  - pattern
  - rag
  - ingestion
  - web
  - langchain
topics:
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[langchain-documents-and-loaders]]"
  - "[[corpus-batch-ingest]]"
  - "[[rag-corpus-coverage-and-abstain]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-moc]]"
source: Distilled from capstone --web / web_phase2 (learning)
---

# Incremental RAG Web Ingest

After PDF tier ingest, add **HTML documentation** with `WebBaseLoader` and a separate corpus list (`web_phase2`). Same Chroma collection, same manifest dedupe — new `source_kind` branch in load/split.

**Layman:** PDFs gave you research papers; web ingest adds the **manual pages** for topics papers skip (e.g. agents, loaders API).

## Why a second phase

| Tier | Content | Gap filled |
|------|---------|------------|
| PDF corpus | Papers (RAG, DPR, Lost in the Middle) | Theory |
| **Web phase** | Official docs HTML | Framework topics (agents, LCEL depth) |

Declare honest scope in corpus JSON — see [[rag-corpus-coverage-and-abstain]].

## Corpus shape

```json
{
  "sources": [ "... PDF entries ..." ],
  "web_phase2": [
    {
      "id": "langchain-agents",
      "title": "LangChain — Agents (HTML)",
      "url": "https://docs.example.com/agents",
      "topics": ["agents", "tools"]
    }
  ],
  "honest_scope": {
    "good_for": ["RAG theory", "retrieval pipeline"],
    "not_enough_for": ["Full API reference without web_phase2"]
  }
}
```

## Load branch

```python
def load_and_split(source_id: str, source_kind: str, loader_path: str | None) -> list:
    if source_kind == "pdf":
        pages = PyPDFLoader(loader_path).load()
    else:
        pages = WebBaseLoader(source_id).load()
    chunks = splitter.split_documents(pages)
    return tag_chunks(chunks, source_id)
```

URL `source_id` = normalized URL string in manifest (same as PDF URL ingest).

## CLI

```python
parser.add_argument("--web", action="store_true", help="Ingest web_phase2 URLs")
# cmd_web: loop corpus["web_phase2"], call ingest_source per URL
```

Reuse [[corpus-batch-ingest]] loop pattern (counts, `quiet_skip`, per-item try/except).

## Usage notes

- **Network** required for fetch + embed
- **HTML noise** — nav chrome may chunk poorly; tune splitters or URLs
- **Append** to existing Chroma — [[chroma-persist-append-and-reingest]]
- Re-run `--web` is cheap when manifest skips unchanged URLs

## See also

- [[python-urllib-urls-and-fetching]]
- [[corpus-batch-ingest]]
- [[rag-moc]]