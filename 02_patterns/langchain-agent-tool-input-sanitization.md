---
title: LangChain Agent Tool Input Sanitization
tags:
  - pattern
  - langchain
  - agents
  - tools
  - python
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-react-agent-executor]]"
  - "[[langchain-react-agent-loop]]"
  - "[[langchain-research-agent-repl]]"
  - "[[rag-moc]]"
source: Distilled from Capstone 04 calculator + Lab 35 Exercise 7 (learning)
---

# LangChain Agent Tool Input Sanitization

ReAct models often emit **messy `Action Input`** — multiple lines, JSON, or leaked `Thought:` / `Final Answer:` text. Utility tools (calculator, parsers) should **sanitize** input before executing.

**Layman:** the worker hands the calculator a scribbled sticky note — you read only the first clean number line.

## Calculator pattern

```python
def _first_line(value: str) -> str:
    line = value.strip().splitlines()[0].strip()
    for sep in ("Final Answer", "Observation", "Thought:"):
        if sep in line:
            line = line.split(sep)[0].strip()
    return line

def calculator(expression: str) -> str:
    try:
        expr = _first_line(expression)
        return f"Result: {eval(expr)}"
    except Exception as e:
        return f"Error calculating: {e}. Use one line like 25+63"
```

Return **errors as Observation strings** — agent can retry with a cleaner Action Input.

## Prompt + tool description pairing

| Layer | Role |
|-------|------|
| ReAct **Rules** | “Action Input like `25+63` — one line, no words” |
| Tool **description** | “Single math expression only, e.g. 25+63” |
| **`_first_line`** | Last-resort parse defense |

## Security note

`eval()` is for **local labs only**. Production: `ast.literal_eval`, safe math parser, or sandboxed REPL.

## See also

- [[langchain-react-agent-executor]]
- [[langchain-research-agent-repl]]