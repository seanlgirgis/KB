---
title: LangChain Classic Chains Overview
tags:
  - langchain
  - chains
  - llm
  - langchain-classic
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-lcel-build-sequence]]"
  - "[[langchain-output-parsers-overview]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[langchain-package-ecosystem]]"
  - "[[capstone-rag-vs-session-memory]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[retrievalqa-chain-type-packing]]"
  - "[[rag-moc]]"
source: Distilled from Lab 34 chains + capstone 02/03 guides (learning)
---

# LangChain Classic Chains Overview

**Classic chains** live in **`langchain_classic.chains`** — pre-LCEL classes that wire **prompt → LLM → (optional next step)**. **`LLMChain`** is one workstation; **`SequentialChain`** is an assembly line of several.

**Layman:** **Chain** = automatic handoff so step 2 uses step 1’s output without you copying strings by hand.

```python
from langchain_classic.chains import LLMChain, SequentialChain
# also: ConversationChain, RetrievalQA, SimpleSequentialChain
```

Courses mirror old Coursera imports: `langchain.chains` → use **`langchain_classic.chains`** in your stack.

## Map at a glance

| Chain | One-line job | Your touchpoints |
|-------|--------------|------------------|
| **`LLMChain`** | One `PromptTemplate` + one LLM call | Building block inside sequences |
| **`SequentialChain`** | Run several `LLMChain`s in order; wire `output_key`s | Lab 34, Capstone 02 review desk |
| **`SimpleSequentialChain`** | Linear pipe — each step has **one** input and **one** output string | Rare in your labs; simpler than `SequentialChain` |
| **`ConversationChain`** | Memory + prompt + LLM each turn | Capstone 03 — [[langchain-remember-me-chat-repl]] |
| **`RetrievalQA`** | Retriever + LLM (RAG) | Capstone 01 — [[langchain-rag-chains-overview]] |

Modern equivalent for many pipelines: **LCEL** (`prompt | llm | parser`) — same logic, different syntax. Full build order: [[langchain-lcel-build-sequence]]; parsers: [[langchain-output-parsers-overview]].

---

## LLMChain — one step

**Meaning:** Run **one prompt** through **one LLM**. Optional **`output_key`** names the result in a shared dict for later steps.

```python
from langchain_classic.chains import LLMChain
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate(
    template="Suggest a classic dish from {location}. YOUR RESPONSE:",
    input_variables=["location"],
)

location_chain = LLMChain(
    llm=llm,
    prompt=prompt,
    output_key="meal",
)

result = location_chain.invoke(input={"location": "China"})
# result["meal"] → LLM text; other keys may include input echo
```

| Piece | Role |
|-------|------|
| `prompt` | Template with `{variables}` |
| `llm` | Watsonx / OpenAI / etc. |
| `output_key` | Label for this step’s output in the dict |
| `invoke(input={...})` | Pass prompt variables |

**LCEL same job:** `prompt | llm | StrOutputParser()` — returns a string, not a dict with `output_key`.

---

## SequentialChain — assembly line

**Meaning:** Run **`LLMChain`s in fixed order**. Later prompts can use **`{review}`**, **`{sentiment}`**, **`{summary}`** from earlier `output_key`s. You declare what enters at the start and what you want back at the end.

```python
overall_chain = SequentialChain(
    chains=[location_chain, dish_chain, recipe_chain],
    input_variables=["location"],
    output_variables=["meal", "recipe", "time"],
    verbose=True,
)

overall_chain.invoke(input={"location": "China"})
```

### Review desk pipeline (Capstone 02 / Lab 34 Exercise 6)

```text
review  →  sentiment_chain   →  sentiment
review + sentiment  →  summary_chain  →  summary
review + sentiment + summary  →  response_chain  →  response
```

```python
traditional_chain = SequentialChain(
    chains=[sentiment_chain, summary_chain, response_chain],
    input_variables=["review"],
    output_variables=["sentiment", "summary", "response"],
)
```

LangChain **automatically** passes accumulated keys into each next `LLMChain` — you do not manually thread strings between invokes.

### Why multi-step beats one mega-prompt

| One giant prompt | SequentialChain |
|------------------|-----------------|
| Hard to debug which “job” failed | Each step has one job |
| Inconsistent structure | Named `output_key`s per stage |
| Re-run whole thing to fix step 2 | Can test each `LLMChain` alone |

**Not in SequentialChain capstones:** Chroma, memory, retrieval — pure **LLM pipeline** over one input blob.

---

## SimpleSequentialChain — linear string pipe

**Meaning:** Like `SequentialChain` but **simpler**: each sub-chain takes **one** string in and returns **one** string out — **no named `output_key` dict**. Good for “translate → summarize → email” with no branching.

```python
from langchain_classic.chains import SimpleSequentialChain

# Illustrative — each chain must have single input/output interface
pipeline = SimpleSequentialChain(chains=[chain_a, chain_b, chain_c], verbose=True)
pipeline.run("raw text input")
```

Your coursework emphasizes **`SequentialChain` + `output_key`** (more explicit). Use `SimpleSequentialChain` when you do not need a growing dict of named fields.

---

## Higher-level classic chains (pointers)

| Chain | Pipeline | Note |
|-------|----------|------|
| **`ConversationChain`** | read memory → prompt → LLM → save memory | [[conversation-buffer-memory]] |
| **`RetrievalQA`** | retrieve chunks → stuff prompt → LLM | [[langchain-rag-chains-overview]] |

Capstone comparison: [[capstone-rag-vs-session-memory]] (01 vs 03); add **02** = SequentialChain over one review, no DB.

---

## invoke conventions (traps)

| Chain | Typical invoke |
|-------|----------------|
| `LLMChain` | `chain.invoke(input={"location": "China"})` |
| `SequentialChain` | `chain.invoke(input={"review": "..."})` |
| `ConversationChain` | `chain.invoke(input="Hello")` — key is **`input`**, not `question` |
| `RetrievalQA` | `chain.invoke("What is RAG?")` or `{"query": "..."}` by version |

Build the **outer** chain once; do not recreate inside a REPL loop (same rule as memory — [[langchain-remember-me-chat-repl]]).

---

## Classic vs LCEL (same pipeline)

Lab 34 shows both:

| Traditional | Modern |
|-------------|--------|
| `LLMChain` + `SequentialChain` | `prompt \| llm \| StrOutputParser()` |
| `output_key` dict wiring | `RunnablePassthrough.assign(...)` |

Pick classic for course alignment and explicit step names; pick LCEL for new apps and middleware.

---

## Beyond fixed chains — agents

When the **LLM** must pick tools (not a fixed step order), use **ReAct** + `AgentExecutor` — not `SequentialChain`. See [[langchain-react-agent-loop]], [[fixed-pipeline-vs-langchain-agent]].

## See also

- [[langchain-lcel-build-sequence]] — four-step LCEL build + `|` syntax
- [[langchain-output-parsers-overview]]
- [[langchain-few-shot-prompt-template]]
- [[langchain-rag-chains-overview]] — RetrievalQA, LCEL RAG, ReAct
- [[langchain-react-agent-loop]]
- [[retrievalqa-chain-type-packing]] — `stuff` / `map_reduce` inside RetrievalQA
- [[langchain-package-ecosystem]] — `langchain_classic` package
- [[rag-moc]]