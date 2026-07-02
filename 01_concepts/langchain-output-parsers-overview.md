---
title: LangChain Output Parsers Overview
tags:
  - langchain
  - lcel
  - parsers
  - prompts
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-lcel-build-sequence]]"
  - "[[langchain-classic-chains-overview]]"
  - "[[langchain-few-shot-prompt-template]]"
  - "[[rag-moc]]"
source: Course assessment alignment (LangChain output parsers)
---

# LangChain Output Parsers Overview

**Output parsers** sit at the **end of an LCEL chain** (`prompt | llm | parser`) and turn raw LLM text into a **typed Python value** — string, list, JSON object, etc.

**Layman:** the LLM talks in free text; the parser is the receptionist who files it into the right folder shape.

## Common parsers

| Parser | Output | Typical use |
|--------|--------|-------------|
| **`StrOutputParser`** | `str` | Plain text answer (default “just give me the string”) |
| **`CommaSeparatedListOutputParser`** | `list[str]` | Comma-separated values — **course CSV-style lists** |
| **`JsonOutputParser`** | `dict` / structured JSON | Nested fields when prompt asks for JSON |
| **`PydanticOutputParser`** | Pydantic model instance | Schema-validated objects |

Import path (core):

```python
from langchain_core.output_parsers import (
    StrOutputParser,
    CommaSeparatedListOutputParser,
)
```

## CSV / comma-separated lists

When the task is **“LLM response → comma-separated list”** (assessment framing for CSV-like output), use **`CommaSeparatedListOutputParser`**.

```python
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import CommaSeparatedListOutputParser

parser = CommaSeparatedListOutputParser()
prompt = PromptTemplate(
    template="List three RAG benefits as comma-separated values.\n{format_instructions}",
    input_variables=[],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

chain = prompt | llm | parser
items = chain.invoke({})  # e.g. ["grounding", "freshness", "citations"]
```

**Note:** this parser expects **comma-separated tokens in one line**, not a full multi-row spreadsheet with headers. For rich tables, use structured JSON + `JsonOutputParser` / Pydantic, then export with `csv` or pandas.

## LCEL placement

Parsers are always the **last** pipe segment:

```python
chain = prompt_template | llm | output_parser
```

Build order: [[langchain-lcel-build-sequence]].

## Pairing with few-shot prompts

When the model needs **examples** of the output shape, combine [[langchain-few-shot-prompt-template]] with parser `get_format_instructions()`.

## See also

- [[langchain-lcel-build-sequence]] — four-step LCEL build + `|` syntax
- [[langchain-classic-chains-overview]] — `StrOutputParser()` as `LLMChain` equivalent
- [[rag-moc]]