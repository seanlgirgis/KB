---
title: RAG Adaptive and Self-RAG Flows
tags:
  - rag
  - agents
  - langchain
  - retrieval
topics:
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[rag-as-agent-tool]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[rag-corpus-coverage-and-abstain]]"
  - "[[rag-moc]]"
source: Promoted from 00_inbox/agent-patterns-langchain.md
---

# RAG Adaptive and Self-RAG Flows

Beyond fixed **RetrievalQA** and simple **RAG tools**, research and production systems add **decision nodes**: skip retrieval, grade chunks, or fall back to web search. Usually built as **LangGraph** or custom graphs — not a single `create_*` in classic agents.

**Layman:** fixed RAG always opens the cabinet. Adaptive RAG asks “do I need the cabinet?” first. Self-RAG checks whether the cards pulled are good enough.

## Pattern sketch

| Pattern | Idea | Extra step vs Capstone 04 |
|---------|------|---------------------------|
| **Adaptive RAG** | Skip retrieval when unnecessary | `grade_need_retrieval` before tool |
| **Self-RAG** | Retrieve → generate → **critique** chunks | `grade_document` → maybe re-retrieve |
| **CRAG** | Correct weak retrieval | `grade` → web search fallback |

Capstone 04 `search_course_docs` is **retrieve-only** inside a tool. These patterns wrap retrieval with **grading** and **branching**.

## Real-world examples

| Scenario | Flow |
|----------|------|
| Medical FAQ | Retrieve only for drug-interaction questions; policy answers without search |
| News desk | Archive RAG first; low chunk scores → web search tool |

## Relation to abstain

[[rag-corpus-coverage-and-abstain]] — LLM refuses when context weak. Self-RAG/CRAG add **machinery** to detect weakness and **retry** or **fallback** before generation.

## Implementation note

Often `StateGraph` with explicit nodes — not `AgentExecutor` alone. Start with working RAG tool ([[rag-as-agent-tool]]) before adding grade nodes.

## See also

- [[langchain-agent-patterns-overview]]
- [[langchain-react-agent-loop]]
- [[rag-troubleshooting-retrieval-first]]
- [[rag-moc]]