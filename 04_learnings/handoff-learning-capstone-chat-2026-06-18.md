---
title: Handoff — Learning Capstone Work (out of kb scope)
tags:
  - learning
  - handoff
  - capstone
  - out-of-scope
topics:
  - software-engineering
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[incremental-rag-ingest-build-order]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[retrievalqa-chain-type-packing]]"
  - "[[kb-home]]"
source: kb Grok session 2026-06-18 — scope correction
---

# Handoff — Learning Capstone Work (out of kb scope)

Sean used the **kb** Grok agent for some **learning/capstone** coding and tutoring. That work belongs in **`D:\Workarea\learning`** with the learning agent — not in kb. This note records what happened, **paths**, and what to continue elsewhere.

**kb agent rule (from 2026-06-18):** non-kb tasks are **rejected immediately**. Distilling concepts into kb notes is OK; editing capstone scripts is not.

---

## What was wrongly done in learning (take to learning agent)

### Capstone chat script — bites implemented by kb agent

**File modified (learning repo, not kb):**

`D:\Workarea\learning\playground\langchain\capstone\capstone_01_chat.py`

| Bite | What was added | Status |
|------|----------------|--------|
| 1 | `from capstone_shared import CHROMA_DIR, chroma_has_data, load_vector_store` | Done in file |
| 2 | `require_chroma_data()` guard | Done in file |
| 3 | `load_chat_vector_store()` → `load_vector_store()` | Done in file |
| 4 | `build_qa_chain()` — retriever k=3, `RetrievalQA`, `make_watsonx_llm()`, smoke `invoke` | Done in file |
| 5 | argv one-shot + `input()` loop | **Not done** — next for learning agent |

**Related learning paths (read-only context for handoff):**

| Path | Role |
|------|------|
| `D:\Workarea\learning\playground\langchain\capstone\capstone_shared.py` | Shared `CHROMA_DIR`, `load_vector_store`, embeddings |
| `D:\Workarea\learning\playground\langchain\capstone\capstone_01_ingest.py` | **Sean's ingest script** (bites 1–6 — his coding) |
| `D:\Workarea\learning\playground\langchain\capstone\capstone01.md` | Course guide — chat bites 1–5 spec |
| `D:\Workarea\learning\playground\langchain\capstone\data\chroma_01\` | Persisted Chroma (799 chunks at time of session) |
| `D:\Workarea\learning\playground\langchain\31.rag.retrieval_qa.py` | Lab reference for RetrievalQA pattern |
| `D:\Workarea\learning\playground\langchain\watson_llm.py` | `make_watsonx_llm()`, embeddings |

**Run (learning):**

```powershell
D:\py_venv\rag_application_builder_foundation\set_env.ps1
cd D:\Workarea\learning\playground\langchain\capstone
python capstone_01_chat.py
```

### Concepts discussed (learning tutor — not kb coding)

Sean paused on bite 4 to understand:

- `vector_store` = LangChain wrapper for Chroma (`langchain_community.vectorstores.Chroma`)
- `as_retriever(k=3)` = tool that fetches top 3 chunks per question (at invoke time)
- `make_watsonx_llm()` = LangChain-runnable Watsonx LLM from shared `watson_llm.py`
- `RetrievalQA.from_chain_type` = retrieve + answer pipeline
- `chain_type="stuff"` = stuffing all chunks into one prompt (not “things”)
- `return_source_documents=False` = answer only in return object; retrieval cost unchanged

**Distilled into kb (appropriate):** [[langchain-rag-chains-overview]], [[retrievalqa-chain-type-packing]]

---

## What was correctly done in kb (`D:\Workarea\kb`)

### Vault / agent setup

| Path | Change |
|------|--------|
| `BOOTSTRAP.md` | Obsidian workflow, paste checklist, **kb-only scope reject** |
| `Grok_PROJECT_PROFILE.md` | Scope hard rule |
| `Grok_PROJECT_MEMORY.md` | One-sheet, paste capture, kb-only scope |
| `docs/NOTE_CONVENTIONS.md` | One-sheet rule, paste capture checklist |
| `.obsidian/` | Moved from nested `KB/` to repo root (nested folder removed) |

### Concept notes (`01_concepts/`)

- `python-project-root-for-imports.md`
- `rag-vector-store-and-ingest-manifest.md`
- `python-hashlib-sha256-fingerprints.md`
- `password-hashing-one-way-storage.md`
- `python-tempfile-temporary-storage.md`
- `python-urllib-urls-and-fetching.md` (includes `is_url`)
- `python-argparse-cli.md`
- `python-json-read-write-files.md`
- `rag-text-chunking-splitters.md`
- `langchain-documents-and-loaders.md`
- `rag-ingest-query-settings-parity.md`
- `pluggable-embedding-models.md`
- `langchain-package-ecosystem.md`
- `retrievalqa-chain-type-packing.md`
- `langchain-rag-chains-overview.md`

### Patterns (`02_patterns/`)

- `normalize-source-url-or-local-path.md`
- `ingest-cli-parser-and-handlers.md`
- `rag-ingest-pipeline-spine.md`
- `read-source-bytes-and-loader-path.md`
- `tag-chunks-with-source-metadata.md`
- `chroma-persist-append-and-reingest.md`
- `ingest-manifest-schema-and-fields.md`
- `corpus-batch-ingest.md`

### Learnings (`04_learnings/`)

- `incremental-rag-ingest-build-order.md`
- `handoff-learning-capstone-chat-2026-06-18.md` (this file)

### Maps (`06_maps/`)

- `rag-moc.md` — full ingest + retrieval index
- `software-engineering-moc.md` — Python/stdlib/patterns links
- `kb-home.md` — unchanged entry point

### Ingest script analysis source (learning, read for kb distill only)

`D:\Workarea\learning\playground\langchain\capstone\capstone_01_ingest.py` — Sean's code; kb distilled A–F gaps into notes above, did not claim ownership of that script.

---

## Suggested next steps for learning agent

1. **Chat bite 5** — `sys.argv` question + `input()` loop until `quit`; print `answer["result"]` cleanly.
2. **Stretch** — `return_source_documents=True`, show `ingest_source_id` / title.
3. **Optional** — Sean re-types bites 1–4 himself for muscle memory (kb agent already edited file).

---

## Suggested next steps for kb agent (in scope)

- Capture chat bite 5 patterns **after** learning agent implements — as generalized `02_patterns/` note if useful.
- Continue paste → curated notes only under `D:\Workarea\kb`.

---

## Follow-up kb distill (2026-06-18 session 2)

Retrieval debug + Watsonx truncate trap distilled to kb — see [[rag-troubleshooting-retrieval-first]], [[watsonx-truncate-input-tokens-rag-trap]], [[debug-retrieval-without-llm]]. Learning code reference only: `capstone/debug_retrieval.py`, `capstone_shared.py` EMBED_PARAMS fix.

## See also

- [[incremental-rag-ingest-build-order]]
- [[langchain-rag-chains-overview]]
- [[retrievalqa-chain-type-packing]]
- [[rag-troubleshooting-retrieval-first]]
- [[rag-moc]]