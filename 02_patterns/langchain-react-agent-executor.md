---
title: LangChain ReAct AgentExecutor Pattern
tags:
  - pattern
  - langchain
  - agents
  - react
topics:
  - software-engineering
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-agent-llm-vs-chat-llm]]"
  - "[[langchain-react-agent-loop]]"
  - "[[rag-as-agent-tool]]"
  - "[[langchain-research-agent-repl]]"
  - "[[suppress-langchain-classic-deprecation-warnings]]"
  - "[[langchain-package-ecosystem]]"
  - "[[rag-moc]]"
source: Distilled from Capstone 04 + Lab 35 (learning)
---

# LangChain ReAct AgentExecutor Pattern

Wire **`create_react_agent`** + **`AgentExecutor`** with a ReAct **`PromptTemplate`**, a tool list, and guardrails (`max_iterations`, `handle_parsing_errors`). Generic pattern for any tool-using agent — research capstone uses RAG + calculator.

**Layman:** hire an executor who runs the think → act → read loop until the job is done or you hit a step limit.

## Imports

```python
from langchain_classic.agents import AgentExecutor, create_react_agent
from langchain_core.prompts import PromptTemplate
from langchain_core.tools import Tool
```

## ReAct prompt skeleton

```python
REACT_PROMPT = PromptTemplate.from_template(
    """You are a research assistant who can use tools.

{tools}

The available tools are: {tool_names}

Follow this format:

Question: the user's question
Thought: think about what to do
Action: the tool to use, one of [{tool_names}]
Action Input: the input to the tool (ONE line only)
Observation: the result from the tool
Thought: I now know the final answer
Final Answer: your final answer

Rules:
- Use search_course_docs for facts from indexed PDFs
- Use calculator for math only; Action Input like 25+63

Question: {input}
{agent_scratchpad}
"""
)
```

Explicit **Rules** reduce garbage `Action Input` and infinite loops — copy discipline from Lab 35 / capstone guide.

## Build executor

```python
def build_agent_executor(tools: list[Tool]) -> AgentExecutor:
    llm = make_watsonx_agent_llm(LLM_PARAMS)  # not chat LLM — [[langchain-agent-llm-vs-chat-llm]]
    agent = create_react_agent(llm=llm, tools=tools, prompt=REACT_PROMPT)
    return AgentExecutor(
        agent=agent,
        tools=tools,
        verbose=True,
        handle_parsing_errors=True,
        max_iterations=8,
    )
```

| Flag | Why |
|------|-----|
| `max_iterations` | Stop runaway Thought/Action loops |
| `handle_parsing_errors` | Recover when model emits malformed Action lines |
| `verbose=True` | Dev: prints Thought/Action/Observation **during** `invoke` to stdout |

With `verbose=True`, REPL still prints only `result["output"]` after each question — but the trace appears **above** the final line. Stretch: `verbose=False` for answer-only UX.

## Invoke

```python
result = executor.invoke({"input": question})
answer = result["output"]
```

Key is **`input`**, same family as `ConversationChain`.

## Traps

| Symptom | Fix |
|---------|-----|
| `KeyError: agent_scratchpad` | Add `{agent_scratchpad}` to template |
| Loops forever | Tighter Rules; lower `max_iterations`; fix tool output |
| Wrong tool chosen | Sharpen **tool `description`** strings |
| Slow / costly | Expected — multiple LLM calls per question |
| `Unsupported parameter: 'stop'` | Chat LLM on agent path | [[langchain-agent-llm-vs-chat-llm]] |

## See also

- [[langchain-agent-llm-vs-chat-llm]]
- [[langchain-react-agent-loop]] — concept
- [[rag-as-agent-tool]] — RAG tool implementation
- [[langchain-agent-tool-input-sanitization]] — `_first_line` for calculator
- [[langchain-research-agent-repl]]
- [[rag-moc]]