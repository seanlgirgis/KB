---
title: LangChain LCEL Build Sequence
tags:
  - langchain
  - lcel
  - chains
  - prompts
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-classic-chains-overview]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[langchain-output-parsers-overview]]"
  - "[[langchain-sequential-chain-review-pipeline]]"
  - "[[rag-moc]]"
source: Course assessment alignment (LangChain / LCEL)
---

# LangChain LCEL Build Sequence

**LCEL** (LangChain Expression Language) builds chains from **Runnable** pieces connected with the **pipe operator** (`|`). The correct build order starts with the **template structure**, ends with **`invoke`**.

**Layman:** write the form letter first, plug in the mailroom (LLM), optionally format the reply, then send one filled-in form.

## Correct sequence (four steps)

| Step | Action |
|------|--------|
| 1 | **Define a template with variables** — decide placeholders (`{topic}`, `{question}`) |
| 2 | **Create a `PromptTemplate`** (or `ChatPromptTemplate`) — bind template string + `input_variables` |
| 3 | **Build the chain with `\|`** — `prompt \| llm \| output_parser` |
| 4 | **Invoke with input variables** — `chain.invoke({"topic": "RAG"})` |

Wrong orders (invoke first, pipe before template, etc.) fail because later steps depend on earlier definitions.

## Minimal example

```python
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

# 1–2: template with variables → PromptTemplate
prompt = PromptTemplate(
    template="Explain {topic} in one sentence.",
    input_variables=["topic"],
)

# 3: pipe operator connects Runnables
chain = prompt | llm | StrOutputParser()

# 4: invoke with variable dict
answer = chain.invoke({"topic": "embeddings"})
```

## Pipe syntax (SequentialChain migration)

Migrating from **`SequentialChain`** to LCEL:

```python
chain = prompt_template | llm | output_parser
```

| Not LCEL | Why |
|----------|-----|
| `prompt.connect(llm)` | No `.connect()` on templates |
| `[prompt, llm, parser]` | List does not compose Runnables |
| `prompt ›› llm` | Wrong operator |

Multi-step dict wiring (review desk): **`RunnablePassthrough.assign(...)`** — see [[langchain-sequential-chain-review-pipeline]], [[langchain-classic-chains-overview]].

## LCEL vs classic (same pipeline)

| Classic | LCEL |
|---------|------|
| `LLMChain` + `invoke(input={...})` | `prompt \| llm \| parser` + `invoke({...})` |
| `SequentialChain` + `output_key` | `RunnablePassthrough.assign` |

Pick classic for course capstones; LCEL for composable production chains — [[langchain-rag-chains-overview]].

## See also

- [[langchain-output-parsers-overview]] — `StrOutputParser`, `CommaSeparatedListOutputParser`
- [[langchain-classic-chains-overview]] — `LLMChain` / `SequentialChain` parallel
- [[suppress-langchain-classic-deprecation-warnings]] — classic → LCEL direction
- [[rag-moc]]