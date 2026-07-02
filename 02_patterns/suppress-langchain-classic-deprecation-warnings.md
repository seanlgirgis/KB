---
title: Suppress LangChain Classic Deprecation Warnings
tags:
  - pattern
  - langchain
  - python
  - warnings
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-package-ecosystem]]"
  - "[[langchain-remember-me-chat-repl]]"
  - "[[langchain-classic-chains-overview]]"
  - "[[rag-moc]]"
source: Distilled from capstone_03 py files (learning)
---

# Suppress LangChain Classic Deprecation Warnings

Course labs still use **`langchain_classic`** (`ConversationChain`, `ConversationBufferMemory`, `LLMChain`). Imports may emit **`DeprecationWarning`** noise that drowns demo output. Capstone 03 filters warnings at startup — **labs only**, not a blanket production practice.

## Pattern (capstone 03)

```python
import warnings

warnings.simplefilter("ignore", DeprecationWarning)
warnings.showwarning = lambda *args, **kwargs: None
```

Place **before** `langchain_classic` imports. Alternative: filter `LangChainDeprecationWarning` from `langchain_core._api` if that is the only category you need.

## When to use

| Use | Skip |
|-----|------|
| Local demos / capstone REPL | Production services |
| You know you are on classic APIs intentionally | Debugging migration to LCEL |

Long-term fix is **LCEL** (`prompt | llm`) — see [[langchain-classic-chains-overview]] — not permanent warning suppression.

## See also

- [[langchain-package-ecosystem]]
- [[langchain-remember-me-chat-repl]]