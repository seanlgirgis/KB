---
title: LangChain Package Ecosystem (Split Packages)
tags:
  - langchain
  - python
  - rag
  - packages
topics:
  - software-engineering
  - retrieval
status: curated
created: 2026-06-18
updated: 2026-06-19
related:
  - "[[rag-pipeline-tool-stages]]"
  - "[[rag-framework-ecosystem-comparison]]"
  - "[[langchain-documents-and-loaders]]"
  - "[[pluggable-embedding-models]]"
  - "[[rag-text-chunking-splitters]]"
  - "[[rag-moc]]"
source:
---

# LangChain Package Ecosystem (Split Packages)

Modern LangChain splits across **multiple pip packages** instead of one monolith. RAG ingest scripts typically import loaders and vector stores from **community**, splitters from **text-splitters**, and core abstractions from **langchain-core**. Stage-by-stage map (load → split → embed → parse): [[rag-pipeline-tool-stages]]. vs LlamaIndex/Haystack: [[rag-framework-ecosystem-comparison]].

**Layman analogy:** a toolbox sold as **drawers** — screwdrivers in one, saws in another. You pull from the right drawer instead of one giant chest.

## Common imports map

| Need | Package (typical) | Example import |
|------|-------------------|----------------|
| PDF / web loaders | `langchain-community` | `PyPDFLoader`, `WebBaseLoader` |
| Chroma store | **`langchain-chroma`** | `from langchain_chroma import Chroma` — see [[langchain-chroma-package]] |
| Text splitter | `langchain-text-splitters` | `from langchain_text_splitters import RecursiveCharacterTextSplitter` |
| Document type | `langchain-core` | `from langchain_core.documents import Document` |
| Classic chains | `langchain-classic` | `LLMChain`, `SequentialChain`, `RetrievalQA`, `ConversationChain` — [[langchain-classic-chains-overview]] |
| Classic agents | `langchain-classic` | `create_react_agent`, `AgentExecutor` — [[langchain-react-agent-executor]] |
| Classic memory | `langchain-classic` | `ConversationBufferMemory`, `ConversationSummaryMemory` |
| Chat history store | `langchain-community` | `ChatMessageHistory` — [[seed-chat-message-history]] |
| Message types | `langchain-core` | `HumanMessage`, `AIMessage` — JSON save/load |
| Tools | `langchain-core` | `Tool` — [[rag-as-agent-tool]] |

Exact import paths change across versions — pin versions in project `requirements.txt`.

## Why the split

- Smaller installs for apps that only need splitters
- Community integrations optional (Chroma, dozens of loaders)
- Core types stable while integrations evolve

## Usage notes

- **`langchain` meta-package** — may re-export; prefer explicit package imports in new code.
- **Version skew** — upgrade `langchain-community` and `langchain-text-splitters` together when debugging import errors.
- **Vendor LLM SDKs** — often separate (`openai`, `ibm-watsonx-ai`, etc.) wrapped by your `make_embedding_model()`.

## See also

- [[rag-pipeline-tool-stages]] — where each package fits in ingest/query
- [[rag-framework-ecosystem-comparison]]
- [[langchain-chroma-package]]
- [[langchain-documents-and-loaders]]
- [[langchain-rag-chains-overview]]
- [[pluggable-embedding-models]]
- [[python-project-root-for-imports]] — when scripts live in nested folders