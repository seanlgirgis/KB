---
title: Capstone 04 Research Agent Complete
tags:
  - learning
  - capstone
  - langchain
  - agents
  - react
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-react-agent-loop]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[langchain-research-agent-repl]]"
  - "[[langchain-agent-llm-vs-chat-llm]]"
  - "[[chroma-dir-version-embedding-provider]]"
  - "[[rag-as-agent-tool]]"
source: capstone04.md + capstone_04_research_agent.py — reconciled 2026-06-19
---

# Capstone 04 Research Agent Complete

**Status: built** (bites 1–7). Default `main()`: **REPL** at `Q:`; smoke tests commented until you uncomment once.

ReAct agent: LLM routes to **RAG tool** and/or **calculator**. Uses `make_watsonx_agent_llm`, shared `chroma_01_openai` from Capstone 01.

## Scripts (learning repo)

| File | Role |
|------|------|
| `capstone_04_research_agent.py` | Agent + REPL (no argparse in core) |
| `capstone04.md` | Guide, traps, done-when |

## REPL behavior (as shipped)

- `verbose=True` on `AgentExecutor` → Thought/Action/Observation trace during `invoke`
- `run_repl` prints **`result["output"]`** only as the labeled user-facing answer line
- Empty line or `quit` / `exit` ends session

## Traps captured in kb

| Trap | Note |
|------|------|
| `stop` parameter error | [[langchain-agent-llm-vs-chat-llm]] |
| Old `chroma_01` vs `chroma_01_openai` | [[chroma-dir-version-embedding-provider]] |
| Verbose trace noise | Stretch S3: `verbose=False` |

## Done-when (all checked)

- [x] Tools registered in prompt
- [x] Math + RAG routing verified
- [x] REPL until quit
- [x] ReAct vs RetrievalQA explained

## KB notes

- [[langchain-react-agent-loop]]
- [[fixed-pipeline-vs-langchain-agent]]
- [[langchain-react-agent-executor]]
- [[langchain-agent-llm-vs-chat-llm]]
- [[chroma-dir-version-embedding-provider]]
- [[rag-as-agent-tool]]
- [[langchain-agent-tool-input-sanitization]]
- [[langchain-research-agent-repl]]

## Stretch (not in core script)

S1 argparse one-shot · S2 `format_text` tool · S3 quiet verbose · S4 compare vs Capstone 01 chat