---
title: RAG as an Agent Tool
tags:
  - pattern
  - rag
  - agents
  - langchain
  - chromadb
topics:
  - retrieval
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-react-agent-loop]]"
  - "[[langchain-react-agent-executor]]"
  - "[[rag-mmr-retriever]]"
  - "[[debug-retrieval-without-llm]]"
  - "[[rag-shared-config-module]]"
  - "[[rag-moc]]"
source: Distilled from Capstone 04 build_rag_tool (learning)
---

# RAG as an Agent Tool

Expose retrieval as a **`Tool`** the agent **may** call — not a fixed retrieve-then-answer chain. The tool returns an **Observation string** (chunk previews); the **agent LLM** writes the **Final Answer**.

**Layman:** librarian is on call — the researcher decides whether to phone them, not every question automatically.

## Design choice

| Approach | Flow |
|----------|------|
| **RetrievalQA** (Capstone 01) | Always retrieve → one LLM answer |
| **RAG tool** (Capstone 04) | Agent may skip → or call tool → observe text → agent answers |

**Do not** nest a full `RetrievalQA` inside the tool — keep the tool **thin**: retriever → format `page_content` → return string.

## Implementation pattern

```python
def build_rag_tool(vector_store) -> Tool:
    retriever = vector_store.as_retriever(
        search_type="mmr",
        search_kwargs={"k": 5, "fetch_k": 20},
    )

    def search_course_docs(query: str) -> str:
        docs = retriever.invoke(query.strip())
        if not docs:
            return "No matching passages in the course index."
        parts = []
        for i, doc in enumerate(docs[:3], start=1):
            parts.append(f"[{i}] {doc.page_content.strip()}")
        return "\n\n".join(parts)

    return Tool(
        name="search_course_docs",
        func=search_course_docs,
        description=(
            "Search indexed course PDFs for facts. "
            "Input: a short question or search phrase about the material."
        ),
    )
```

## Alignment with fixed RAG chat

Use the **same** `load_vector_store()`, MMR `k` / `fetch_k` as Capstone 01 chat — [[rag-ingest-query-settings-parity]], [[rag-mmr-retriever]]. Debug retrieval with [[debug-retrieval-without-llm]] before blaming the agent.

## Tool description matters

Vague description → agent never calls RAG. Be explicit: “indexed course PDFs”, “factual lookup”.

## Prerequisites

`require_chroma()` / ingest on **current** `CHROMA_DIR` — same guard as [[rag-chat-cli-repl]]. If you swapped embedding provider, old vectors live in a different folder — [[chroma-dir-version-embedding-provider]] (`--corpus --force`).

Retriever fetches up to **k=5** (MMR) but tool formats **top 3** chunk texts for Observation — keeps agent context smaller than full chat stuff.

## See also

- [[fixed-pipeline-vs-langchain-agent]]
- [[langchain-react-agent-executor]]
- [[langchain-research-agent-repl]]
- [[rag-moc]]