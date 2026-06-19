---
title: Ingest Manifest Schema and Fields
tags:
  - pattern
  - rag
  - ingestion
  - json
topics:
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[python-json-read-write-files]]"
  - "[[normalize-source-url-or-local-path]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[rag-ingest-pipeline-spine]]"
source:
---

# Ingest Manifest Schema and Fields

The ingest **manifest** is a small JSON ledger your pipeline owns. It records **which sources** were embedded, **content fingerprints**, and **index settings** at ingest time. It is not the vector store — it is the desk log beside the filing cabinet.

## Top-level shape

```json
{
  "version": 1,
  "chunk_size": 500,
  "chunk_overlap": 50,
  "sources": {
    "https://example.com/paper.pdf": {
      "title": "paper.pdf",
      "kind": "pdf",
      "content_hash": "7eb7a0e69595d0ab5c92b32ee7f7d365d8165d87f073da29c5b8c36c7fd02c01",
      "chunk_count": 57,
      "ingested_at": "2026-06-18T20:00:48.674240+00:00"
    },
    "https://python.langchain.com/docs/concepts/agents/": {
      "title": "LangChain Agents",
      "kind": "web",
      "content_hash": "abc123...",
      "chunk_count": 12,
      "ingested_at": "2026-06-19T10:00:00+00:00"
    }
  }
}
```

## Field reference

| Field | Level | Purpose |
|-------|-------|---------|
| `version` | root | Schema evolution — bump when you break layout |
| `chunk_size` | root | Document index chunk setting used for this vault |
| `chunk_overlap` | root | Overlap setting paired with chunk_size |
| `sources` | root | Map of `source_id` → per-source record |
| `title` | source | Display name (filename or catalog title) |
| `kind` | source | `"pdf"` or `"web"` — which loader branch ran |
| `content_hash` | source | SHA-256 of raw bytes — dedupe key |
| `chunk_count` | source | Sanity check after split |
| `ingested_at` | source | UTC ISO timestamp of last successful ingest |

**`source_id` keys** — output of [[normalize-source-url-or-local-path]] (stripped URL or absolute path).

## Empty manifest on first run

```python
def load_manifest(path, chunk_size, chunk_overlap) -> dict:
    if not path.exists():
        return {
            "version": 1,
            "chunk_size": chunk_size,
            "chunk_overlap": chunk_overlap,
            "sources": {},
        }
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)
```

## Write after successful embed

Only update manifest when Chroma persist succeeded — avoids “logged but not embedded” drift.

```python
manifest.setdefault("sources", {})[source_id] = {
    "title": title or Path(source_id).name,
    "kind": source_kind,  # from read_source_bytes
    "content_hash": content_hash,
    "chunk_count": len(chunks),
    "ingested_at": datetime.now(timezone.utc).isoformat(),
}
save_json(manifest_path, manifest)
```

## Usage notes

- **Hash bytes, not path** — see [[python-hashlib-sha256-fingerprints]].
- **`--list` reads manifest only** — fast inventory without opening Chroma.
- **Version migrations** — if you add fields, teach `load_manifest` to upgrade old files.
- **kb vault future** — same schema idea for markdown paths + file hashes.

## See also

- [[python-json-read-write-files]]
- [[rag-ingest-query-settings-parity]]
- [[ingest-cli-parser-and-handlers]]