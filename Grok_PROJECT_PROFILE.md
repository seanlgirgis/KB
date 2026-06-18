# Grok Project Profile — Knowledge Base (kb)

**For:** Grok Build director and delegated agents discovering this repository  
**Repository:** `D:\Workarea\kb`  
**Profile version:** 2026-06-18

---

## One-Line Summary

Personal Obsidian-style knowledge vault for RAG and software-engineering mastery — capture ideas, patterns, and snippets today; design every note for future vector search and Grok-assisted recall.

---

## Mission Statement

**To build a personal, evolving Knowledge Base that accelerates mastery of RAG and software engineering by capturing useful ideas, code snippets, patterns, and learnings in a clean Obsidian vault today, while designing it from the ground up to become a powerful, queryable RAG system powered by a Vector Database tomorrow.**

### Supporting Vision

- **Short-term:** Visually rich, well-organized Obsidian vault as a daily learning companion — easy capture, connect, and revisit.
- **Long-term:** Transform the vault into a Grok-assisted RAG system for natural queries over personal knowledge.
- **Core principles:** Clarity, consistency, reusability, progressive enhancement — every note is immediately useful and future-proof for AI consumption.

---

## Project Type

| Field | Value |
|-------|-------|
| Name | `kb` (Knowledge Base) |
| Type | Private knowledge vault (Obsidian-first; RAG-ready) |
| Path | `D:\Workarea\kb` |
| Git | Initialized; Sean manages Git unless explicitly delegated |
| Agent file prefix | `Grok_` |

---

## Purpose

kb is Sean's personal engineering and RAG learning vault. Grok Build creates and refines notes from ideas and facts discovered while studying or building.

**Does this project:**

- Capture atomic concept notes, patterns, code snippets, and session learnings
- Maintain Obsidian-style wikilinks, tags, and maps of content (MOCs)
- Enforce RAG-friendly note structure (frontmatter, chunkable headings, stable titles)
- Hold inbox → curated note workflows (`00_inbox/` → topic folders)
- Bridge daily Obsidian use with future embedding / vector DB ingestion

**Does not:**

- Store LTIM/BOA work onboarding or TechAcademy employment material (use **ALOK**)
- Host structured Coursera/DataCamp course packages or StudyBubbles (use **learning**)
- Store one-line command/path nuggets or encrypted secrets (use **local_memory**)
- Run production apps, LifeVault pod workflows, or clipboard tooling
- Commit secrets, credentials, or raw confidential exports

---

## When to Route Work Here

Route tasks to kb when they involve:

- Personal RAG concepts, chunking strategies, embedding patterns, vector DB design
- Software-engineering ideas, design patterns, architecture notes from self-study
- Code snippets and reusable patterns worth linking across notes
- "Capture this idea for my knowledge base" / Obsidian note creation
- Vault structure, note templates, MOCs, or RAG-import conventions
- Future ingestion pipeline design (metadata only until explicitly built)

---

## When Not to Use kb

| Instead use | When |
|-------------|------|
| **ALOK** | Work-learning, onboarding, employer training |
| **learning** | Course packages, skill units, labs, StudyBubbles |
| **local_memory** | Command nuggets, login steps, secret vault |
| **LifeVault** | File lifecycle, publish/quarantine, operational vault DB |

---

## Mandatory Read Order

Before any kb task, read in this order — then **only** paths directly related to the task:

1. [BOOTSTRAP.md](BOOTSTRAP.md) — operating rules and work modes
2. [README.md](README.md) — folder map and quick start
3. [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md) — Obsidian + RAG note format
4. [Grok_PROJECT_MEMORY.md](Grok_PROJECT_MEMORY.md) — stable architecture (when design context is needed)
5. [Grok_CURRENT_STATE.md](Grok_CURRENT_STATE.md) — active priorities (planning or status work)

Do **not** scan the entire vault by default.

---

## Folder Map (Abbreviated)

```text
00_inbox/         Quick capture; unprocessed ideas
01_concepts/      Atomic concept notes
02_patterns/      Design and code patterns
03_snippets/      Reusable code blocks
04_learnings/     Session and lesson captures
05_references/    External docs, papers, links
06_maps/          Maps of content (MOCs)
99_templates/     Obsidian note templates
docs/             Governance and conventions
```

Markdown notes are authoritative. See [docs/VAULT_MODEL.md](docs/VAULT_MODEL.md) for lifecycle and RAG-readiness rules.

---

## Work Modes

### 1. Bite-sized capture (default)

- One idea, snippet, or concept → one note (or inbox stub)
- Update only the local note and nearest MOC if needed
- Do **not** update `Grok_CURRENT_STATE.md` or bulk-reorganize folders

### 2. Section curation

- After several related captures: refine links, update MOCs, merge duplicates
- May add or adjust templates and `docs/` conventions

### 3. Milestone / RAG prep

- Vault-wide audits, ingestion schema, embedding pipeline design
- May update `Grok_PROJECT_MEMORY.md`, `Grok_CURRENT_STATE.md`, and governance docs

---

## Hard Rules

- **RAG-ready by default:** YAML frontmatter, clear H2 sections, stable filenames.
- **Obsidian-native:** wikilinks `[[note-title]]`, tags, MOCs in `06_maps/`.
- **Atomic notes:** one main idea per file; link out instead of duplicating.
- **Proportional work:** small input → small change set.
- **No Git operations** unless Sean explicitly delegates.
- **Report exactly** which files were created, modified, or deleted.
- **Do not invent facts.** Label uncertainty clearly.
- **Agent files** use the `Grok_` prefix.

---

## Delegation Prompt Template

```text
Project: kb (Obsidian knowledge vault — RAG-ready)
Root: D:\Workarea\kb

Read first:
- Grok_PROJECT_PROFILE.md
- BOOTSTRAP.md
- docs/NOTE_CONVENTIONS.md
- [task-specific paths only]

Work mode: [bite-sized | section curation | milestone]

Task:
[one narrowly scoped task]

Must not:
- Run Git operations unless delegated
- Store work onboarding (ALOK), course packages (learning), or command nuggets (local_memory)
- Update Grok_CURRENT_STATE.md unless milestone work
- Commit secrets or raw confidential material

At completion:
- List every file created, modified, or deleted
- Note unresolved ambiguity
- State whether the task completed successfully
```

---

## Related Grok Files

| File | Role |
|------|------|
| `Grok_PROJECT_PROFILE.md` | This file — discovery and briefing |
| `Grok_PROJECT_MEMORY.md` | Stable vault and RAG architecture decisions |
| `Grok_CURRENT_STATE.md` | Active priorities and follow-ups |
| `BOOTSTRAP.md` | Session operating rules |

## Director

Grok Director (`D:\Workarea\Grok_DIRECTOR`) routes files and tasks. Canonical registry: `Grok_DIRECTOR_REGISTRY.md`.

## Custodian

Grok is custodian of `Grok_*` agent files. Vault notes and governance docs are updated per task scope.