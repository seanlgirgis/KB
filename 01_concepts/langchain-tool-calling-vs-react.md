---
title: LangChain Tool Calling vs ReAct
tags:
  - langchain
  - agents
  - react
  - tools
  - llm
topics:
  - software-engineering
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-react-agent-loop]]"
  - "[[langchain-react-agent-executor]]"
  - "[[langchain-agent-llm-vs-chat-llm]]"
  - "[[rag-moc]]"
source: Promoted from 00_inbox/agent-patterns-langchain.md
---

# LangChain Tool Calling vs ReAct

Both patterns let the LLM **route work to tools**. **ReAct** uses **text** (`Thought`, `Action`, `Action Input`) that the framework parses. **Tool calling** uses the chat API’s **structured tool calls** (`tool_name` + arguments as JSON).

**Layman:** ReAct = the model writes instructions in plain English lines. Tool calling = the model fills out a form the API understands.

## Comparison

| | **ReAct (text)** | **Tool / function calling** |
|--|------------------|----------------------------|
| **Model output** | Parsed text lines | Structured `tool_calls` |
| **Classic factory** | `create_react_agent` | `create_tool_calling_agent` |
| **Runtime** | `AgentExecutor` | `AgentExecutor` |
| **LLM requirement** | **`stop` sequences** — [[langchain-agent-llm-vs-chat-llm]] | Models with native tool schema |
| **Course labs** | Lab 35, Capstone 04 | Production OpenAI/Anthropic apps |
| **Failure mode** | Parse errors on messy text | Schema / binding issues |

Agent **role** is the same; **wire format** differs. See [[langchain-agent-patterns-overview]].

## ReAct (text) — example

```python
from langchain_classic.agents import AgentExecutor, create_react_agent

agent = create_react_agent(llm=agent_llm, tools=tools, prompt=react_prompt)
executor = AgentExecutor(agent=agent, tools=tools, handle_parsing_errors=True)
executor.invoke({"input": "What is 25 + 63?"})
```

Full wiring: [[langchain-react-agent-executor]].

## Tool calling — example

```python
from langchain_classic.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant with tools."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])
agent = create_tool_calling_agent(llm, tools, prompt)
executor = AgentExecutor(agent=agent, tools=tools)
```

LLM typically gets `.bind_tools(tools)` inside the factory.

## When to prefer which

| Prefer ReAct | Prefer tool calling |
|--------------|---------------------|
| Learning — visible Thought trace | Production — fewer parse failures |
| Models without tool API | OpenAI / Anthropic native tools |
| Course `langchain_classic` alignment | New apps + `create_agent` (LangGraph) |

## Real-world sketches

| ReAct-style visibility | Tool calling |
|------------------------|--------------|
| Internal research desk with logged traces | SaaS bot calling `reset_password` + `fetch_invoice` |
| Capstone router demo | DevOps assistant with `kubectl_scale` + `log_query` |

## Modern path

`from langchain.agents import create_agent` — LangGraph under the hood, tool-calling style. See overview in [[langchain-agent-patterns-overview]].

## See also

- [[langchain-react-agent-loop]]
- [[fixed-pipeline-vs-langchain-agent]]
- [[rag-moc]]