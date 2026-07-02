---
title: LangChain Agent LLM vs Chat LLM
tags:
  - langchain
  - agents
  - llm
  - react
topics:
  - software-engineering
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-react-agent-executor]]"
  - "[[langchain-research-agent-repl]]"
  - "[[pluggable-embedding-models]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[rag-moc]]"
source: Distilled from watson_llm agent vs chat factories + Capstone 04 (learning)
---

# LangChain Agent LLM vs Chat LLM

**ReAct agents** need an LLM that supports **`stop` sequences** so the parser can cut off after `Observation:` / before the next `Thought:`. **Chat chains** (`RetrievalQA`, `ConversationChain`) use a general chat LLM. Using the wrong factory breaks agents with `Unsupported parameter: 'stop'`.

**Layman:** agent brain must understand “stop here” between tool steps; plain chat does not use that interrupt pattern.

## Two factories (same provider stack)

| Factory | Use for |
|---------|---------|
| **`make_watsonx_llm()`** (or project chat LLM) | RetrievalQA, ConversationChain, LLMChain |
| **`make_watsonx_agent_llm()`** (or project agent LLM) | `create_react_agent` + `AgentExecutor` |

Capstone 04:

```python
from watson_llm import make_watsonx_agent_llm

LLM_PARAMS = {GenParams.TEMPERATURE: 0.2, GenParams.MAX_NEW_TOKENS: 512}

def make_llm():
    return make_watsonx_agent_llm(LLM_PARAMS)
```

## Stop-sequence trap

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Unsupported parameter: 'stop'` | Chat model (e.g. some gpt-5.x configs) rejects stop | **Agent factory** picks ReAct-safe model (e.g. `gpt-4o-mini` fallback) |
| Agent parse errors | Wrong LLM class | Never pass `make_watsonx_llm()` to `create_react_agent` |

Optional env override: `OPENAI_AGENT_MODEL` for agent-specific model id while chat uses `OPENAI_MODEL`.

## Params note

Agent runs use **more tokens per question** (many Thoughts). Capstone 04 uses `max_new_tokens: 512` vs 256 for remember-me chat — tune per task.

## See also

- [[langchain-react-agent-executor]]
- [[langchain-research-agent-repl]]
- [[langchain-remember-me-chat-repl]] — chat LLM only
- [[rag-moc]]