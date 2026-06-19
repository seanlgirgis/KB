---
title: Corpus Batch Ingest
tags:
  - pattern
  - rag
  - ingestion
  - cli
  - json
topics:
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[incremental-rag-web-ingest]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[ingest-cli-parser-and-handlers]]"
  - "[[python-json-read-write-files]]"
  - "[[ingest-manifest-schema-and-fields]]"
source:
---

# Corpus Batch Ingest

A **corpus file** lists many sources (URLs or paths) with titles. A batch command loops them through the same `ingest_source` spine, counts outcomes, and continues after individual failures — like running checkout for a stack of books instead of one at a time.

**Layman analogy:** a reading list JSON file. The script walks each title, tries ingest, tallies “new / updated / skipped / failed,” and prints a report at the end.

## Corpus file shape

```json
{
  "sources": [
    {"id": "paper-a", "title": "Overview Paper", "url": "https://example.com/a.pdf"},
    {"id": "paper-b", "title": "Methods Paper", "url": "https://example.com/b.pdf"}
  ]
}
```

Use `url` or `path` consistently; your loop passes the string to `ingest_source`.

## Batch handler pattern

```python
def cmd_corpus(corpus_path: Path, *, force: bool = False) -> None:
    if not corpus_path.exists():
        print(f"Missing corpus: {corpus_path}")
        sys.exit(1)

    corpus = load_json(corpus_path)
    counts: dict[str, int] = {}

    for item in corpus.get("sources", []):
        source = item.get("url") or item.get("path")
        title = item.get("title", item.get("id", source))
        try:
            status = ingest_source(
                source,
                title=title,
                force=force,
                quiet_skip=True,
            )
            counts[status] = counts.get(status, 0) + 1
            if status == "skipped":
                print(f"Skip (unchanged): {title}")
        except Exception as exc:
            counts["failed"] = counts.get("failed", 0) + 1
            print(f"Failed: {title} — {exc}")

    print(
        "Corpus run:",
        f"ingested={counts.get('ingested', 0)}",
        f"updated={counts.get('updated', 0)}",
        f"skipped={counts.get('skipped', 0)}",
        f"failed={counts.get('failed', 0)}",
    )
```

## quiet_skip

In single-source CLI, print skip details. In batch, pass `quiet_skip=True` inside `ingest_source` to avoid duplicate noise — then print one line per skipped title in the loop (as above).

## CLI wiring

```python
parser.add_argument(
    "--corpus",
    action="store_true",
    help="Ingest all sources from corpus.json",
)
# main: if args.corpus: cmd_corpus(CORPUS_PATH, force=args.force)
```

## Web phase (`web_phase2` + `--web`)

PDF batch uses `corpus["sources"]`. HTML docs use a **separate list** — same loop pattern, different loader:

```python
parser.add_argument("--web", action="store_true", help="Ingest web_phase2 URLs")
# for item in corpus.get("web_phase2", []): ingest_source(url, ...)
```

See [[incremental-rag-web-ingest]] for `WebBaseLoader` branch and [[rag-corpus-coverage-and-abstain]] for `honest_scope` in corpus JSON.

## Usage notes

- **Idempotent runs** — manifest skip makes re-running corpus cheap.
- **`--force`** — re-embed entire list even when hashes match.
- **Partial failure** — one bad URL should not abort the whole batch unless you choose strict mode.
- **Rate limits** — sleep between embed calls if the API throttles.
- **Topics field** — document what each source covers; helps explain abstain vs corpus gap.

## See also

- [[incremental-rag-web-ingest]]
- [[rag-corpus-coverage-and-abstain]]
- [[rag-ingest-pipeline-spine]]
- [[ingest-cli-parser-and-handlers]]
- [[python-json-read-write-files]]