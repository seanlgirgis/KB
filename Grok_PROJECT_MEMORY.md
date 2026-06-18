# kb — Project Memory

Stable architecture and durable decisions. Update when vault design or RAG strategy changes — not after every note capture.

**Last updated:** 2026-06-18 (one-sheet rule)

---

## Why kb exists

Sean needs a vault separate from **learning** (structured courses), **ALOK** (work-learning), and **local_memory** (command nuggets). kb holds personal engineering and RAG knowledge as an Obsidian graph that will later feed a vector database.

---

## Design principles

| Principle | Meaning |
|-----------|---------|
| Clarity | One main idea per note; plain language summaries |
| Consistency | Shared frontmatter, tags, templates, folder rules |
| Reusability | Snippets and patterns linkable from many notes |
| Progressive enhancement | Works in Obsidian today; RAG metadata baked in from day one |

---

## Vault topology

```text
00_inbox/       Capture buffer — promote or delete, never hoard
01_concepts/    Atomic ideas (what/why)
02_patterns/    Repeatable approaches (how)
03_snippets/    Copy-paste-ready code
04_learnings/   Session notes from study or experiments
05_references/  External sources with local commentary
06_maps/        MOCs — navigation only, not canonical content
99_templates/   Note scaffolds for Grok Build
```

**Lifecycle:** inbox → curated folder → linked in MOC → (future) embedded in vector store.

---

## RAG strategy (phased)

### Phase 1 — Now (Obsidian vault)

- Markdown + YAML frontmatter
- Chunk-friendly H2 sections
- Stable filenames and `title` field for embedding labels
- Tags and `topics` for filter metadata

### Phase 2 — Later (ingestion)

- Export or scan `*.md` excluding `00_inbox/` and `99_templates/`
- Chunk on H2 boundaries with title + tags as metadata
- Deduplicate by file path + content hash

### Phase 3 — Future (query)

- Vector DB (choice TBD — Pinecone, Chroma, pgvector, etc.)
- Grok-assisted natural-language queries over personal knowledge
- Re-ingest on note update; track `updated` frontmatter

No embedding pipeline is implemented yet. Do not block daily capture on tooling.

---

## Relationship to other projects

| Project | Relationship |
|---------|--------------|
| **learning** | Courses and labs may *inform* kb notes; copy distilled insights here, not full course trees |
| **ALOK** | Work training stays in ALOK; personal RAG study insights come to kb |
| **local_memory** | Commands and env setup stay in local_memory; conceptual "how it works" notes go to kb |
| **LifeVault** | File lifecycle ops; kb is note-centric, not file-pod-centric |

---

## Tag vocabulary (starter)

Use sparingly; extend as the vault grows.

- `rag`, `embeddings`, `chunking`, `retrieval`, `vector-db`
- `python`, `langchain`, `llm`
- `pattern`, `architecture`, `testing`, `devops`
- `stub` — note intentionally incomplete

---

## Durable decisions

- **Agent prefix:** `Grok_` for agent files in this repo
- **Bootstrap file:** `BOOTSTRAP.md` (not `GROK_RUNBOOK.md`)
- **Default work mode:** bite-sized capture
- **One-sheet rule (2026-06-18):** Tightly coupled concept + short example → **one note** in `01_concepts/` or `02_patterns/` with an H2 **Example** section (code + usage notes). RAG chunks on H2, not file count; one sheet improves human reading and single-hit LLM context. Split to `03_snippets/` only when the same block is reused across 3+ notes or code-only retrieval is explicitly needed. Canonical detail: [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md#one-sheet-rule-concept--example).
- **Obsidian:** primary editor; no custom plugin requirements yet
- **Git:** Sean manages; kb folder already has `.git` initialized
- **Python venv:** use `D:\py_venv\rag_application_builder_foundation\set_env.ps1` only when a task runs Python (ingestion scripts, experiments)

---

## Open questions

- [ ] Which vector DB for phase 3?
- [ ] Obsidian `.obsidian/` config — commit minimal settings or gitignore all?
- [ ] Add kb to `C:\scripts\gitqall.ps1` when remote is configured?