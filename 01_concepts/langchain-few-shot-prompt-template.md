---
title: LangChain FewShotPromptTemplate
tags:
  - langchain
  - prompts
  - llm
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-output-parsers-overview]]"
  - "[[langchain-lcel-build-sequence]]"
  - "[[rag-custom-qa-prompt]]"
  - "[[langchain-classic-chains-overview]]"
  - "[[rag-moc]]"
source: Course assessment alignment (LangChain prompts)
---

# LangChain FewShotPromptTemplate

**`FewShotPromptTemplate`** wraps a base prompt with **example input/output pairs** (“shots”) so the LLM sees the **pattern you want** before answering the real question.

**Layman:** show two worked homework problems, then assign the third — the model copies the style and format.

## Purpose

| Goal | How few-shot helps |
|------|-------------------|
| Fixed output format | Examples show exact shape (JSON lines, bullet list, tone) |
| Classification labels | Examples map text → category |
| Tool-style discipline | Examples show when to abstain or cite |

**Not for:** storing chat history (use memory — [[langchain-memory-types-overview]]). **Not for:** executing outputs without the LLM — examples only **guide** generation.

## Sketch

```python
from langchain_core.prompts import FewShotPromptTemplate, PromptTemplate

examples = [
    {"input": "2+2", "output": "4"},
    {"input": "3+5", "output": "8"},
]

example_prompt = PromptTemplate(
    input_variables=["input", "output"],
    template="Input: {input}\nOutput: {output}",
)

few_shot = FewShotPromptTemplate(
    examples=examples,
    example_prompt=example_prompt,
    prefix="Solve the math problem.",
    suffix="Input: {question}\nOutput:",
    input_variables=["question"],
)
```

Pipe into LCEL like any other prompt: `few_shot | llm | parser` — [[langchain-lcel-build-sequence]].

## vs zero-shot `PromptTemplate`

| | `PromptTemplate` | `FewShotPromptTemplate` |
|--|------------------|-------------------------|
| **Guidance** | Instructions only | Instructions + **concrete examples** |
| **Tokens** | Lower | Higher (examples in every call) |
| **Your RAG labs** | [[rag-custom-qa-prompt]] rules | Rare in capstones; useful for format-sensitive extraction |

## See also

- [[langchain-output-parsers-overview]] — `get_format_instructions()` + few-shot
- [[langchain-lcel-build-sequence]]
- [[rag-moc]]