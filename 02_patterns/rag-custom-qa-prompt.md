---
title: RAG Custom QA Prompt Template
tags:
  - pattern
  - rag
  - langchain
  - prompts
  - llm
topics:
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[retrievalqa-chain-type-packing]]"
  - "[[rag-corpus-coverage-and-abstain]]"
  - "[[rag-mmr-retriever]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from RetrievalQA custom prompt pattern (learning capstone chat)
---

# RAG Custom QA Prompt Template

Default `RetrievalQA` prompts are generic. A **`PromptTemplate`** with explicit rules reduces noise: ignore irrelevant passages, refuse to invent, don’t echo benchmark Q&A tables from research PDFs.

**Layman:** give the writer a style guide for how to read the index cards.

## Wire into RetrievalQA

```python
from langchain_core.prompts import PromptTemplate
from langchain_classic.chains import RetrievalQA

QA_PROMPT = PromptTemplate(
    input_variables=["context", "question"],
    template="""You answer ONE user question using ONLY information from the context.

Rules:
- Use only context that pertains to the question; ignore unrelated passages.
- Do not repeat example Q&A from research papers in the context.
- Do not ask follow-up questions or add off-topic material.
- If none of the passages help, say the indexed sources do not cover it.

Context:
{context}

User question: {question}

Answer:""",
)

qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    chain_type_kwargs={"prompt": QA_PROMPT},
    return_source_documents=False,
)
```

`chain_type_kwargs={"prompt": ...}` overrides the default stuff prompt while keeping retrieve → stuff → generate flow.

## Rules worth encoding

| Rule | Why |
|------|-----|
| **On-topic only** | MMR still returns some irrelevant chunks |
| **No paper example Q&A** | DPR/Lost-in-the-Middle PDFs contain fake user questions |
| **Abstain when no support** | [[rag-corpus-coverage-and-abstain]] |
| **No follow-ups** | Keeps CLI one-shot answers clean |

## Debug order

Tune prompt **after** [[debug-retrieval-without-llm]] shows on-topic hits. Prompt cannot fix broken embeddings ([[watsonx-truncate-input-tokens-rag-trap]]).

## LLM params (separate knob)

```python
CHAT_LLM_PARAMS = {"temperature": 0.2, "max_new_tokens": 512}
llm = make_llm(CHAT_LLM_PARAMS)
```

Lower temperature → stick to context. See [[rag-llm-size-vs-retrieval-quality]].

## See also

- [[rag-corpus-coverage-and-abstain]]
- [[rag-mmr-retriever]]
- [[rag-moc]]