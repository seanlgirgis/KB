---
title: LangChain ReAct Agent Loop
tags:
  - langchain
  - agents
  - react
  - llm
  - tools
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[langchain-agent-llm-vs-chat-llm]]"
  - "[[langchain-react-agent-executor]]"
  - "[[rag-as-agent-tool]]"
  - "[[langchain-classic-chains-overview]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from Capstone 04 + Lab 35 (learning)
---

# LangChain ReAct Agent Loop

**ReAct** (Reason + Act) is an agent pattern: the LLM **interleaves reasoning** with **tool calls** until it can emit a **Final Answer**. LangChain classic implements it via **`create_react_agent`** + **`AgentExecutor`**.

**Layman:** fixed chain = assembly line with a fixed order. **ReAct agent** = worker who reads the question, thinks, picks a tool, reads the result, thinks again — maybe repeats — then answers.

## The loop

```text
Question
  → Thought      (what should I do?)
  → Action       (tool name)
  → Action Input (one line to the tool)
  → Observation  (tool output string)
  → Thought      (continue or done?)
  → … repeat …
  → Final Answer
```

One **Thought** often means **one LLM call** — agents cost more than a single `RetrievalQA.invoke`.

## What the model sees

The ReAct **prompt template** must include:

| Variable | Role |
|----------|------|
| `{tools}` | Descriptions of every tool |
| `{tool_names}` | Comma list for the Action line |
| `{input}` | User question |
| `{agent_scratchpad}` | Prior Thought/Action/Observation steps in this run |

Missing `{agent_scratchpad}` → `KeyError` at runtime. The scratchpad is how the model “remembers” what it already tried **within one question** — not session memory ([[conversation-buffer-memory]]).

## ReAct vs fixed RAG

| | **RetrievalQA** (fixed) | **ReAct agent** |
|--|-------------------------|-----------------|
| **Who picks retrieve?** | You — always | **LLM** — sometimes |
| **Steps** | retrieve → stuff → answer | 0–N tool calls, variable order |
| **Math + docs in one Q** | Awkward (still retrieves) | Natural (calculator + RAG tools) |
| **“Hello”** | Still hits Chroma | May skip tools |

When every question needs corpus context, fixed RAG is simpler. When the question might need **lookup**, **math**, or **neither**, an agent helps — [[fixed-pipeline-vs-langchain-agent]].

## Interview one-liner

> ReAct means the model alternates **thoughts** and **tool actions**, using each **observation** to decide the next step until it produces a final answer.

## See also

- [[langchain-agent-patterns-overview]] — full pattern map and when to use each
- [[langchain-react-agent-executor]] — `create_react_agent`, `max_iterations`
- [[rag-as-agent-tool]] — retriever inside a tool, not nested chain
- [[langchain-rag-chains-overview]]
- [[rag-moc]]