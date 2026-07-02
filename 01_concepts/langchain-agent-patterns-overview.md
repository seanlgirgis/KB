---
title: LangChain Agent Patterns Overview
tags:
  - langchain
  - agents
  - react
  - tools
  - rag
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-react-agent-loop]]"
  - "[[langchain-tool-calling-vs-react]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[langchain-agent-llm-vs-chat-llm]]"
  - "[[rag-as-agent-tool]]"
  - "[[langchain-research-agent-repl]]"
  - "[[rag-adaptive-self-crag-flows]]"
  - "[[agentic-rag-web-service-stack]]"
  - "[[rag-moc]]"
source: Promoted from 00_inbox/agent-patterns-langchain.md; Capstone 04 + Lab 35
---

# LangChain Agent Patterns Overview

An **agent** is the role: the LLM **chooses and runs tools** in a loop until it can answer. **ReAct** is one recipe for that role (text `Thought` → `Action` → `Observation`). **Tool calling** is another (structured API calls). LangChain classic exposes many `create_*_agent` factories; modern apps often use **`langchain.agents.create_agent`** (LangGraph).

**Layman:** fixed RAG = always open the filing cabinet. Agent = worker with a toolkit who decides whether to search, calculate, or answer from memory.

## Integrating with external tools

An agent does **not** run one new hardcoded command per user request. The **language model decides the next action** (which tool, what input); the framework **calls external tools** — vector DBs, calculators, HTTP APIs, SQL — and feeds **observations** back until the model can answer.

```text
User request → LLM picks action → tool hits database/service → observation → LLM again → Final Answer
```

Capstone 04: [[rag-as-agent-tool]] (Chroma) + calculator — [[langchain-research-agent-repl]].

## Agent vs fixed RAG (30 seconds)

| | **Fixed RAG** | **Agent** |
|--|---------------|-----------|
| **Who routes?** | You — hardcoded chain | LLM — tool loop |
| **Vector DB** | Every question | Only when a tool needs it |
| **Your build** | `RetrievalQA` | ReAct + tools — [[langchain-research-agent-repl]] |

Deep comparison: [[fixed-pipeline-vs-langchain-agent]].

## Pattern map (quick reference)

| Pattern | Core idea | Classic entry | Runtime |
|---------|-----------|---------------|---------|
| **ReAct (text)** | Reason in text, name tool, read observation | `create_react_agent` | `AgentExecutor` |
| **Tool / function calling** | Structured tool calls (JSON) | `create_tool_calling_agent` | `AgentExecutor` |
| **OpenAI tools / functions** | Vendor-specific tool API shapes | `create_openai_tools_agent`, `create_openai_functions_agent` | `AgentExecutor` |
| **Structured / JSON / XML chat** | Fixed message format for actions | `create_structured_chat_agent`, `create_json_chat_agent`, `create_xml_agent` | `AgentExecutor` |
| **Self-ask with search** | Sub-questions → search each | `create_self_ask_with_search_agent` | `AgentExecutor` |
| **Vectorstore router** | Pick *which* index to query | `create_vectorstore_router_agent` | `AgentExecutor` |
| **Plan-and-execute** | Plan all steps, then execute | `PlanAndExecute` | `langchain_experimental` |
| **Graph / state machine** | Explicit nodes and edges | `create_agent` | LangGraph `CompiledStateGraph` |
| **Supervisor / multi-agent** | Lead delegates to specialists | `create_supervisor` (LangGraph) | LangGraph |

**Course / capstone path:** `langchain_classic.agents` + [[langchain-react-agent-loop]]. **New apps:** `from langchain.agents import create_agent`.

## Choosing a pattern

| Need | Start here |
|------|------------|
| Learning labs, text trace you can read | **ReAct** — [[langchain-react-agent-executor]] |
| Production OpenAI/Anthropic tool use | **Tool calling** — [[langchain-tool-calling-vs-react]] |
| Long jobs with visible plan | **Plan-and-execute** (experimental) |
| Many vector indexes (HR vs eng) | **Vectorstore router** |
| Team of specialist agents | **Supervisor / multi-agent** (LangGraph) |
| Approvals, retries, persistence, HITL | **LangGraph** / `create_agent` |
| Every question needs docs | **Skip agent** — fixed RAG |

## ReAct (your capstone build)

Text loop until `Final Answer`. Implementation: [[langchain-react-agent-loop]], [[langchain-react-agent-executor]]. LLM: [[langchain-agent-llm-vs-chat-llm]] (`stop` sequences). RAG as optional tool: [[rag-as-agent-tool]].

**Real-world:** field-service copilot (manual search + schedule API); internal desk (HR docs + calculator for pro-rated days).

## Tool calling (production sibling)

Same router *idea*, structured calls instead of parsing `Thought:` lines. See [[langchain-tool-calling-vs-react]].

## Plan-and-execute

Planner writes multi-step plan upfront; executor runs one step at a time with tools. Contrast: ReAct decides one hop at a time. Use for trip planning, due-diligence reports with visible milestones. Package: `langchain_experimental.plan_and_execute`.

## Self-ask with search

Hard question → follow-up sub-questions → search each → compose answer. Multi-hop QA (legal lookup, product comparison). `create_self_ask_with_search_agent` + search chain.

## Vectorstore router

**Which index?** before retrieval. Enterprise KB: route “parental leave UK” to `hr_uk` not `engineering_runbooks`. Contrast Capstone 04: single `search_course_docs` corpus — router adds **multiple** stores + routing step.

## Supervisor / multi-agent

Supervisor delegates to specialists (researcher, writer, coder). LangGraph `create_supervisor` or custom graph. Marketing campaigns, incident triage.

## Graph agents (`create_agent`)

Explicit graph: nodes = steps, edges = conditions. Supports persistence, interrupts, human-in-the-loop. Loan approval, support ticket escalate paths. `langgraph.prebuilt.create_react_agent` deprecated in favor of `langchain.agents.create_agent`.

## RAG-specialized flows (conceptual)

Often **custom LangGraph** — not one classic `create_*`:

| Pattern | Idea |
|---------|------|
| **Adaptive RAG** | Skip retrieval when unnecessary |
| **Self-RAG** | Retrieve → generate → **grade** chunks → maybe re-retrieve |
| **CRAG** | Weak retrieval → web or fallback |

Capstone 04 RAG tool is the **retrieve** half; adaptive/self-RAG add **grading** nodes around it — [[rag-adaptive-self-crag-flows]].

## Provider portability

Framework supplies **patterns**; you still handle **provider dialects** (stop sequences, embeddings, tool schemas). Use an adapter layer (chat LLM vs agent LLM factories) + contract tests per vendor — [[langchain-agent-llm-vs-chat-llm]], [[pluggable-embedding-models]].

## Capstone 04 fit

```text
User question → AgentExecutor → create_react_agent
  → agent LLM (stop-safe)
  → Thought / Action
      → search_course_docs (optional Chroma)
      → calculator (optional)
  → Final Answer
```

| Capstone 01 | Capstone 04 |
|-------------|-------------|
| Always retrieve + answer | Sometimes search tool; agent writes answer |
| Chat LLM factory | Agent LLM factory |

## See also

- [[langchain-react-agent-loop]]
- [[langchain-tool-calling-vs-react]]
- [[rag-adaptive-self-crag-flows]]
- [[langchain-rag-chains-overview]]
- [[capstone-04-research-agent-2026-06-19]]
- [[agentic-rag-web-service-stack]] — expose agents as HTTP
- [[rag-moc]]