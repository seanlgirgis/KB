# Note Conventions — Obsidian + RAG Ready

Every curated note in kb should work in Obsidian today and ingest into a vector DB tomorrow without rework.

---

## Filename rules

- Format: `kebab-case-short-title.md`
- Stable: rename only when the concept genuinely changes
- No version suffixes (`_final`, `_v2`)

Examples: `recursive-chunking.md`, `python-project-imports.md`

---

## Required frontmatter

```yaml
---
title: Human Readable Title
tags:
  - rag
  - chunking
topics:
  - retrieval
  - text-splitting
status: curated   # inbox | curated | stub | archived
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[parent-moc-or-note]]"
source: optional URL or course reference
---
```

| Field | Purpose |
|-------|---------|
| `title` | Display name and embedding label |
| `tags` | Filter facets for search and RAG metadata |
| `topics` | Broader subject grouping |
| `status` | Workflow state |
| `related` | Graph edges (wikilinks) |
| `source` | Provenance |

---

## Body structure

1. **Summary** — one paragraph answering what this note is and when to use it
2. **H2 sections** — one subtopic per section (natural chunk boundaries)
3. **Examples** — code or diagrams when applicable
4. **See also** — wikilinks to related notes

```markdown
# Human Readable Title

One-paragraph summary for humans and chunk context.

## Core idea

...

## When to use

...

## Example

\`\`\`python
# snippet
\`\`\`

## See also

- [[related-note]]
- [[relevant-moc]]
```

---

## Wikilinks and tags

- Prefer `[[note-title]]` over relative paths in prose
- If the target note does not exist yet, set `status: stub` on the new note or leave a `[[stub-note]]` and create inbox stub
- Tags in frontmatter; avoid duplicating as `#inline` unless useful in Obsidian graph view

---

## Folder placement

| Content type | Folder |
|--------------|--------|
| Definition, mental model | `01_concepts/` |
| Repeatable approach | `02_patterns/` |
| Copy-paste code | `03_snippets/` |
| Study session write-up | `04_learnings/` |
| Paper, doc, link commentary | `05_references/` |
| Index / navigation | `06_maps/` |
| Unprocessed | `00_inbox/` |

---

## One-sheet rule (concept + example)

**Decision (2026-06-18):** Default to **one note** when an idea and its code example are tightly coupled. Optimizes for human reading (one scroll) and RAG retrieval (shared title/tags; H2 sections become natural chunks).

### Default — one sheet

Put concept, when-to-use, **and** copy-paste code in a single note:

- **Folder:** `01_concepts/` (mental model) or `02_patterns/` (repeatable how-to)
- **Structure:** summary → core idea → when to use → **Example** (code fence) → usage notes
- **RAG:** ingestors chunk on H2; one file beats split files when `k=1` retrieval must return both explanation and code

### Split to `03_snippets/` only when

- The **same** code block is linked from **three or more** notes, or
- Sean explicitly wants a code-only retrieval target (e.g. filter `folder:03_snippets`)

Do **not** split a small example into a separate snippet file “for convention’s sake.”

### Examples

| Situation | Organization |
|-----------|--------------|
| Python `sys.path` root hack + how to pick `parent` depth | One concept note with Example section |
| Generic `requests` retry wrapper used by many notes | Snippet in `03_snippets/` + wikilinks from concepts |

---

## RAG chunking hints

Write so an automated splitter can use H2 boundaries:

- Keep sections 100–500 words when possible
- Put code blocks inside the section they illustrate
- Avoid walls of bullet-only content without prose context
- First line after each H2 should stand alone as chunk context

---

## What not to put in notes

- Passwords, API keys, tokens
- Employer-confidential material (use ALOK with sanitization rules)
- Full course dumps (distill into kb; link to learning repo)