---
title: Fixed Pipeline vs LangChain Agent
tags:
  - langchain
  - agents
  - architecture
  - rag
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-react-agent-loop]]"
  - "[[capstone-rag-vs-session-memory]]"
  - "[[langchain-classic-chains-overview]]"
  - "[[langchain-sequential-chain-review-pipeline]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from capstones 01–04 comparison (learning)
---

# Fixed Pipeline vs LangChain Agent

**Fixed pipeline:** you wire steps in code — they run in the same order every time. **Agent:** the **LLM chooses** which tools to call, how many times, and in what order.

**Layman:** chain = conveyor belt. Agent = researcher with a toolkit who decides what to open.

## Capstone map (who decides?)

| | **01 RAG** | **02 Review desk** | **03 Memory** | **04 Agent** |
|--|------------|-------------------|---------------|--------------|
| **Decider** | You (always retrieve) | You (3 LLM chains) | You (memory + 1 LLM) | **LLM** (tool loop) |
| **Chroma** | Always | No | No | **Sometimes** (RAG tool) |
| **Session memory** | No | No | Yes (buffer) | No (typical 04) |
| **Pattern** | `RetrievalQA` | `SequentialChain` | `ConversationChain` | `AgentExecutor` + ReAct |

## When to use which

| Situation | Prefer |
|-----------|--------|
| Every answer needs indexed docs | **Fixed RAG** — [[langchain-rag-chains-overview]] |
| Same 3-step transform every input | **SequentialChain** — [[langchain-sequential-chain-review-pipeline]] |
| Remember user facts this chat | **Buffer memory** — [[conversation-buffer-memory]] |
| Question may need RAG, math, or skip tools | **ReAct agent** — [[langchain-react-agent-loop]] |
| Question mixes lookup + computation | **Agent** with RAG tool + calculator |

## Cost and predictability

| | Fixed chain | Agent |
|--|-------------|-------|
| **LLM calls** | Usually 1 ( + embed) | 1+ per Thought |
| **Tool calls** | Fixed | Model-dependent |
| **Debugging** | Linear | Trace Thought/Action/Observation |
| **Risk** | Wrong retrieval | Loops, wrong tool, parse errors |

Cap production paths with `max_iterations` and clear tool descriptions — [[langchain-react-agent-executor]].

## Combining later

Real assistants may use **session memory** + **RAG tool** + **utilities** in one agent. Capstones teach each piece alone first.

## See also

- [[langchain-agent-patterns-overview]]
- [[langchain-react-agent-loop]]
- [[rag-as-agent-tool]]
- [[capstone-rag-vs-session-memory]]
- [[rag-moc]]