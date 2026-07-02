---
title: LangChain Sequential Chain Review Pipeline
tags:
  - pattern
  - langchain
  - chains
  - llm
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-classic-chains-overview]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[capstone-rag-vs-session-memory]]"
  - "[[rag-custom-qa-prompt]]"
  - "[[rag-moc]]"
source: Distilled from Lab 34 Exercise 6 + Capstone 02 review desk (learning)
---

# LangChain Sequential Chain Review Pipeline

Repeatable **3-step LLM assembly line**: product **review** in → **sentiment**, **summary**, **customer response** out. Built from three **`LLMChain`**s inside one **`SequentialChain`**. No Chroma, no session memory — state is a **passing dict** between steps.

**Layman:** factory line — sentiment station, summary station, reply station; each adds labeled output to the package.

## Pipeline

```text
review → sentiment_chain → summary_chain → response_chain
         (sentiment)       (summary)        (response)
```

Later prompts include earlier variables:

```text
{review}
{review} + {sentiment}
{review} + {sentiment} + {summary}
```

## Three LLMChains

```python
sentiment_chain = LLMChain(llm=llm, prompt=sentiment_prompt, output_key="sentiment")
summary_chain = LLMChain(llm=llm, prompt=summary_prompt, output_key="summary")
response_chain = LLMChain(llm=llm, prompt=response_prompt, output_key="response")
```

Each `PromptTemplate` declares only the variables it needs (`review`, `sentiment`, `summary`).

## SequentialChain wrapper

```python
from langchain_classic.chains import SequentialChain

review_chain = SequentialChain(
    chains=[sentiment_chain, summary_chain, response_chain],
    input_variables=["review"],
    output_variables=["sentiment", "summary", "response"],
    verbose=False,
)

result = review_chain.invoke(input={"review": review_text})
```

## vs other capstones

| Capstone | Pattern |
|----------|---------|
| 01 RAG | `RetrievalQA` — retrieve then one LLM |
| 02 Review desk | **`SequentialChain`** — three LLMs, one input |
| 03 Memory | `ConversationChain` — multi-turn buffer |

## LCEL stretch

Same logic with `RunnablePassthrough.assign` — Lab 34 bite 9. See [[langchain-classic-chains-overview]].

## See also

- [[langchain-classic-chains-overview]] — `LLMChain` / `SequentialChain` definitions
- [[rag-custom-qa-prompt]] — single-step prompt discipline (contrast)
- [[rag-moc]]