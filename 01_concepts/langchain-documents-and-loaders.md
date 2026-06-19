---
title: LangChain Documents and Loaders
tags:
  - rag
  - langchain
  - document-loaders
  - pdf
topics:
  - indexing
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[rag-text-chunking-splitters]]"
  - "[[read-source-bytes-and-loader-path]]"
  - "[[langchain-package-ecosystem]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[rag-moc]]"
source:
---

# LangChain Documents and Loaders

In LangChain-style RAG, a **`Document`** is the unit of text plus metadata moving through your pipeline. A **loader** reads a source format (PDF, HTML, markdown file) and returns a list of `Document` objects. A **splitter** then cuts those into retrieval-sized chunks.

**Layman analogy:** the loader is the **scanner** that digitizes pages; each `Document` is one scanned page with a sticky note (metadata). Chunking cuts pages into paragraphs that fit the search index.

## Document structure

```python
# Conceptual shape (LangChain Document)
document.page_content  # str — the text to embed and retrieve
document.metadata      # dict — source, page number, custom tags
```

- **`page_content`** — what the embedding model sees (plus what the LLM may read after retrieval).
- **`metadata`** — filters, citations, delete-by-source keys — not always embedded; stored alongside vectors.

One PDF might load as **one Document per page** or one per file depending on loader.

## Loader role in the pipeline

```text
file path  →  Loader.load()  →  [Document, Document, ...]
           →  Splitter        →  [smaller Document chunks]
           →  Embed + store
```

Loaders do **not** chunk by default for PDFs — they extract text; you split explicitly.

## Example — PDF loader

```python
from langchain_community.document_loaders import PyPDFLoader

def load_pages(loader_path: str) -> list:
    """loader_path: local filesystem path (not URL string)."""
    return PyPDFLoader(loader_path).load()
```

Pair with [[read-source-bytes-and-loader-path]] when sources can be URLs.

## Other loaders (same idea)

| Loader (examples) | Source |
|-------------------|--------|
| `TextLoader` | `.txt` with encoding |
| `UnstructuredMarkdownLoader` | `.md` |
| `WebBaseLoader` | URL HTML (loader fetches; alternative to manual urlopen) |

Pick loader by **file type**; keep normalize/hash logic in your ingest layer.

## When to use LangChain loaders

- Standard formats with community-maintained parsers
- You already use LangChain vector stores and splitters

## When not to use

- Custom vault markdown with frontmatter — you may parse yourself into `Document`
- Binary formats without a maintained loader — extract text another way

## Usage notes

- Loaders expect **paths** for many file types — stage URL downloads first.
- Preserve **page numbers** in metadata when the loader provides them — helps citations.
- Empty pages — PDFs may yield blank `page_content`; splitter still runs; consider filtering.

## See also

- [[rag-text-chunking-splitters]]
- [[tag-chunks-with-source-metadata]]
- [[langchain-package-ecosystem]]
- [[rag-ingest-pipeline-spine]]