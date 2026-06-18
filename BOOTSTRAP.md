# kb Bootstrap

## Project Purpose

kb is Sean's personal Obsidian-style knowledge vault for RAG and software-engineering mastery. Grok Build turns ideas and facts from learning sessions into clean, linkable, RAG-import-friendly notes.

## Repository Identity

- Path: `D:\Workarea\kb`
- Do not create a competing vault or duplicate registry elsewhere.
- Sean manages Git unless he explicitly delegates a Git action.

## Startup Rule

For every task:

1. Read this file.
2. Read [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md) when creating or editing notes.
3. Read only files directly relevant to the requested task.
4. Read [Grok_PROJECT_MEMORY.md](Grok_PROJECT_MEMORY.md) only when stable architecture context is needed.
5. Read [Grok_CURRENT_STATE.md](Grok_CURRENT_STATE.md) only for milestone, planning, or status work.
6. Do not scan the whole vault unless the task explicitly requires an audit.

## Source-of-Truth Order

1. Individual notes in topic folders (`01_concepts/` … `05_references/`)
2. Maps of content in `06_maps/`
3. Templates in `99_templates/`
4. Governance in `docs/`
5. Agent state: `Grok_PROJECT_MEMORY.md`, `Grok_CURRENT_STATE.md`

Do not invent missing facts. Mark uncertainty clearly.

## Note Creation Workflow

### Quick capture (inbox)

1. Drop a stub in `00_inbox/` with title + one-paragraph gist.
2. Add minimal frontmatter (`title`, `tags`, `status: inbox`).
3. Link to related notes if known.

### Curated note (default output from Grok Build)

1. Choose the correct folder by type (concept, pattern, snippet, learning, reference).
2. **One-sheet default:** if idea + code example are tightly coupled, keep them in one `01_concepts/` or `02_patterns/` note with an H2 **Example** section — do not split into `03_snippets/` unless the block is reused across 3+ notes. See [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md#one-sheet-rule-concept--example).
3. Apply the matching template from `99_templates/`.
4. Fill frontmatter completely.
5. Write chunk-friendly sections (H2 per subtopic).
6. Add wikilinks to related notes and update the relevant MOC in `06_maps/` when useful.
7. Remove or archive inbox stub after promotion.

## Work Modes

### 1. Bite-Sized Capture Mode (default)

Use for one idea, snippet, pattern, or short learning session.

Default work:

- create or update one note (or inbox stub)
- **user paste → full standards pass** — see [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md#paste-capture-checklist-grok-build); never dump pasted markdown as-is
- complete frontmatter (`tags`, `topics`, `related`), H2 chunks, MOC update, cross-links

Do **not** update after every bite-sized item unless explicitly requested:

- `Grok_CURRENT_STATE.md`
- `Grok_PROJECT_MEMORY.md`
- vault-wide reorganizations
- bulk template or convention changes

### 2. Section Curation Mode

Use after several related notes or when a topic area matures.

May update:

- MOCs in `06_maps/`
- cross-links between related notes
- templates and `docs/NOTE_CONVENTIONS.md` refinements

### 3. Milestone / RAG Prep Mode

Use for ingestion schema, embedding pipeline design, vault audits, or major structure changes.

May update:

- `Grok_PROJECT_MEMORY.md`
- `Grok_CURRENT_STATE.md`
- `docs/VAULT_MODEL.md`
- ingestion-related scripts or config (when they exist)

## Obsidian Rules

- Filenames: `kebab-case-title.md` — stable, human-readable, URL-safe.
- Links: prefer `[[wikilinks]]` over bare paths.
- Tags: use frontmatter `tags:` array; keep tags lowercase and consistent.
- MOCs: index notes live in `06_maps/`; do not duplicate full content there.
- Images and attachments: `attachments/` (create when needed); link with relative paths.

## RAG-Readiness Rules

Every curated note should be ingestible without rework:

- YAML frontmatter with `title`, `tags`, `topics`, `created`, `status`
- Self-contained sections under H2 headings (good chunk boundaries)
- First paragraph summarizes the note (useful as chunk context)
- `related:` or wikilinks for graph context
- No secrets, tokens, or PII

## File Editing Rules

- Inspect the target file before editing.
- Preserve intended filenames unless renaming is part of the task.
- Use relative links.
- Prefer small, direct edits.
- Avoid `_final`, `_updated`, `_new` suffixes.
- Do not modify unrelated files.
- Do not perform Git operations unless explicitly requested.

## Validation Rule

Match validation effort to task size.

For bite-sized work:

- confirm expected note exists with valid frontmatter
- confirm wikilinks resolve to existing notes or are marked `stub`
- check only links touched by the task

Do not run vault-wide link scans unless requested.

## Completion Report

Keep completion reports short.

For bite-sized work, report only:

- files created or changed
- unresolved ambiguity
- whether the requested work completed successfully

## Detailed References

Use only when relevant:

- [Grok_PROJECT_PROFILE.md](Grok_PROJECT_PROFILE.md)
- [Grok_PROJECT_MEMORY.md](Grok_PROJECT_MEMORY.md)
- [docs/VAULT_MODEL.md](docs/VAULT_MODEL.md)
- [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md)
- [README.md](README.md)