---
title: Ingest CLI — Parser and cmd_* Handlers
tags:
  - pattern
  - python
  - argparse
  - cli
  - ingestion
topics:
  - software-engineering
  - indexing
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[python-argparse-cli]]"
  - "[[rag-vector-store-and-ingest-manifest]]"
  - "[[normalize-source-url-or-local-path]]"
  - "[[python-hashlib-sha256-fingerprints]]"
  - "[[python-json-read-write-files]]"
  - "[[corpus-batch-ingest]]"
  - "[[rag-ingest-pipeline-spine]]"
  - "[[software-engineering-moc]]"
  - "[[rag-moc]]"
source:
---

# Ingest CLI — Parser and cmd_* Handlers

RAG ingest scripts benefit from a **thin CLI layer**: `build_parser()` defines flags, `main()` dispatches to small **`cmd_*` handlers**, and each handler does one job (list manifest, debug a source, run full ingest). Parsing stays separate from I/O so you can test handlers with plain Python calls. This pattern generalizes any tool that reads [[rag-vector-store-and-ingest-manifest]], probes sources, and optionally writes Chroma.

## Problem

- One script must support **list**, **debug probe**, and **ingest** without tangled `if` chains in `main()`.
- `--list` should read the **manifest only** — not load the vector store.
- **Probe** mode should print normalize + hash + byte size **without** mutating manifest or Chroma (safe debugging).
- Positional `source` should accept URL or path via [[normalize-source-url-or-local-path]].

## Approach

1. **`build_parser()`** — all `add_argument` definitions; return `ArgumentParser`.
2. **`cmd_list()`** — introspect manifest; human-readable summary.
3. **`cmd_probe(source)`** — read bytes, print fingerprint; no side effects.
4. **`main()`** — `parse_args()` then dispatch; default help when no action.

See [[python-argparse-cli]] for argparse mechanics.

## Example — manifest list handler

Read ledger only — answers “what did we already ingest?” without opening the vector DB.

```python
def cmd_list() -> None:
    """Print sources recorded in the ingest manifest (--list)."""
    manifest = load_manifest()
    sources = manifest.get("sources", {})
    if not sources:
        print("No sources ingested yet.")
        return
    print(f"Ingested sources ({len(sources)}):")
    for source_id, meta in sources.items():
        title = meta.get("title", source_id)
        chunks = meta.get("chunk_count", "?")
        print(f"  • {title}  chunks={chunks}")
        print(f"    id: {source_id}")
```

**Use when:** verifying manifest rows, chunk counts, and canonical `source_id` strings after ingest runs.

## Example — probe handler (debug, no writes)

Dry-run path: normalize, read bytes, show hash prefix and loader staging path. Does **not** update manifest or vector store.

```python
def cmd_probe(source: str) -> None:
    """Debug ingest path: resolve source, read bytes, print fingerprint."""
    raw, loader_path, kind = read_source_bytes(source)
    print("source_id:", normalize_source(source))
    print("kind:", kind)
    print("bytes:", len(raw))
    print("hash:", sha256_bytes(raw)[:16], "...")
    print("loader_path:", loader_path)
```

Wire to a flag, e.g. `--probe SOURCE`, or a subcommand. Pair with [[python-hashlib-sha256-fingerprints]].

## Example — build_parser and dispatch

Generic ingest CLI — rename description and wire `--corpus` when batch ingest exists.

```python
import argparse


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Ingest sources into a vector store with manifest dedupe.",
    )
    parser.add_argument(
        "source",
        nargs="?",
        default=None,
        help="File path or URL to ingest",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="Show ingest manifest entries",
    )
    parser.add_argument(
        "--probe",
        metavar="SOURCE",
        help="Debug: normalize, hash, and read bytes without ingesting",
    )
    parser.add_argument(
        "--corpus",
        action="store_true",
        help="Batch ingest PDFs from corpus_sources.json",
    )
    parser.add_argument(
        "--web",
        action="store_true",
        help="Batch ingest web_phase2 URLs from corpus_sources.json",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-embed even if content hash unchanged",
    )
    return parser


def main() -> None:
    args = build_parser().parse_args()

    if args.list:
        cmd_list()
        return
    if args.probe:
        cmd_probe(args.probe)
        return
    if args.corpus:
        cmd_corpus(force=args.force)
        return
    if args.web:
        cmd_web(force=args.force)
        return
    if args.source is None:
        build_parser().print_help()
        return

    ingest_source(args.source, force=args.force)


# Optional: default source when arg omitted (labs only)
# source = args.source or DEFAULT_SOURCE_URL
# Prefer print_help() in production tools unless you document the default.


if __name__ == "__main__":
    main()
```

## Tradeoffs

- **Flags vs subcommands** — `ingest.py --list` is simpler than `ingest list`; subcommands scale better with many modes.
- **`--probe` as optional flag** — keeps one positional free for default ingest; alternative is `nargs` subparsers.
- **`cmd_*` in same file** — fine for small tools; split module when handlers grow past ~30 lines each.

## Usage notes

- **`--list` never touches Chroma** — fast sanity check after failed ingests.
- **`cmd_probe` before wiring embed** — confirms URL fetch, path resolve, and hash match expectations.
- **`--force`** — bypass manifest skip when chunking rules change but file bytes do not.
- **Default `source`** — labs may use `args.source or DEFAULT_URL`; production tools usually print help instead.
- **Batch corpus** — see [[corpus-batch-ingest]] for `cmd_corpus` loop and summary counts.
- **`--web`** — see [[incremental-rag-web-ingest]] for `cmd_web` and `web_phase2` corpus tier.
- **Dispatch order** — check boolean flags (`--list`) before positional ingest.

## See also

- [[python-argparse-cli]] — `ArgumentParser`, `store_true`, `nargs="?"`
- [[rag-vector-store-and-ingest-manifest]] — manifest schema and skip logic
- [[normalize-source-url-or-local-path]] — `source_id` in list/probe output
- [[python-urllib-urls-and-fetching]] — URL sources for probe/ingest
- [[corpus-batch-ingest]] — `--corpus` batch mode
- [[rag-ingest-pipeline-spine]] — what `ingest_source` runs
- [[software-engineering-moc]]
- [[rag-moc]]