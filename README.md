# kb — Personal Knowledge Base

Obsidian-style vault for RAG and software-engineering mastery. Designed for daily learning now and vector search later.

## Mission

Build a personal, evolving knowledge base that accelerates mastery of RAG and software engineering — capture ideas in a clean Obsidian vault today; query it with Grok-assisted RAG tomorrow.

## Quick start

### Open in Obsidian

1. Open Obsidian → **Open folder as vault**
2. Select `D:\Workarea\kb`

### Start Grok Build session

```powershell
pwsh -ExecutionPolicy Bypass -File "C:\scripts\start_grok_kb.ps1"
```

### Capture an idea

1. Grok creates a note in `00_inbox/` or the right topic folder
2. Use a template from `99_templates/`
3. Link from the relevant MOC in `06_maps/`

## Folder map

| Folder | Purpose |
|--------|---------|
| `00_inbox/` | Quick capture, unprocessed |
| `01_concepts/` | Atomic ideas |
| `02_patterns/` | Design and code patterns |
| `03_snippets/` | Reusable code |
| `04_learnings/` | Session captures |
| `05_references/` | External sources |
| `06_maps/` | Maps of content (MOCs) |
| `99_templates/` | Note templates |
| `docs/` | Conventions and vault model |

## Grok agent files

| File | Read when |
|------|-----------|
| [Grok_PROJECT_PROFILE.md](Grok_PROJECT_PROFILE.md) | Director handoff / discovery |
| [BOOTSTRAP.md](BOOTSTRAP.md) | Every Grok Build session |
| [docs/NOTE_CONVENTIONS.md](docs/NOTE_CONVENTIONS.md) | Creating or editing notes |
| [Grok_PROJECT_MEMORY.md](Grok_PROJECT_MEMORY.md) | Architecture / RAG decisions |
| [Grok_CURRENT_STATE.md](Grok_CURRENT_STATE.md) | Status and priorities |

## Related projects

- **learning** — structured courses and labs (`D:\Workarea\learning`)
- **ALOK** — work-learning vault (`D:\Workarea\ALOK`)
- **local_memory** — command nuggets and runbooks
- **Grok Director** — routing (`D:\Workarea\Grok_DIRECTOR`)