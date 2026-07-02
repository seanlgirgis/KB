---
title: LangChain Research Agent REPL
tags:
  - pattern
  - langchain
  - agents
  - cli
  - rag
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[langchain-agent-llm-vs-chat-llm]]"
  - "[[chroma-dir-version-embedding-provider]]"
  - "[[langchain-react-agent-executor]]"
  - "[[rag-as-agent-tool]]"
  - "[[rag-chat-cli-repl]]"
  - "[[rag-shared-config-module]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[rag-moc]]"
source: Distilled from capstone_04_research_agent.py (learning)
---

# LangChain Research Agent REPL

End-to-end **research agent** script shape: guard Chroma → build tools → `AgentExecutor` → smoke tests → REPL. Capstone 04 merges **Capstone 01 index** with **ReAct** tool routing.

**Layman:** one desk — question in; agent picks RAG search or calculator; answer out.

## main() story order

```text
1. require_chroma()           # ingest prerequisite
2. store = load_vector_store()
3. rag_tool = build_rag_tool(store)
4. calc_tool = build_calculator_tool()
5. executor = build_agent_executor([rag_tool, calc_tool])
   print("Agent executor ready:", [t.name for t in executor.tools])
6. run_smoke_tests(executor)   # commented in main — uncomment once to verify routing
7. run_repl(executor)            # default path
```

Read `main()` first — helpers follow same order ([[bare-vs-full-script-tier]] habit).

## Shared dependencies

| Module | Provides |
|--------|----------|
| `capstone_shared` | `load_vector_store`, `chroma_has_data`, `CHROMA_DIR` |
| `watson_llm` | **`make_watsonx_agent_llm`** only — not `make_watsonx_llm` ([[langchain-agent-llm-vs-chat-llm]]) |

**Prerequisite:** ingest on current `CHROMA_DIR` (e.g. after embedding provider swap — [[chroma-dir-version-embedding-provider]]). Docstring: `chroma_01_openai` + `set_env.ps1`.

No argparse in shipped script — REPL only; one-shot = stretch S1. No conversation memory — each question is independent.

## Smoke test matrix

| Question | Expected routing |
|----------|------------------|
| `What is 25 + 63?` | **calculator** (not RAG) |
| `What is retrieval augmented generation?` | **search_course_docs** |
| `15 * 7 and is RAG in my notes?` | **Both** tools (order may vary) |
| `Hello` | May **skip** tools |

## Smoke tests (bite 6)

```python
def run_question(executor, text: str) -> str:
    result = executor.invoke({"input": text})
    print(f"Final Answer: {result['output']}")
    return result["output"]

def run_smoke_tests(executor) -> None:
    for q in ("What is 25 + 63?", "What is retrieval augmented generation?"):
        run_question(executor, q)
```

Uncomment `run_smoke_tests(executor)` in `main()` once after bites 1–5 — then rely on REPL.

## REPL (bite 7 — default)

```python
def run_repl(executor: AgentExecutor) -> None:
    print("Research agent (empty line or 'quit' to exit)")
    while True:
        question = input("Q: ").strip()
        if not question or question.lower() in ("quit", "exit"):
            break
        result = executor.invoke({"input": question})
        print(result["output"])  # final answer only; verbose=True may print trace above
        print()
```

Build **executor once** before loop — same rule as [[rag-chat-cli-repl]].

## Traps (verified in REPL)

| Symptom | Fix |
|---------|-----|
| `Unsupported parameter: 'stop'` | [[langchain-agent-llm-vs-chat-llm]] |
| No store but old ingest exists | [[chroma-dir-version-embedding-provider]] `--corpus --force` |
| Noisy Thought/Action lines | `verbose=False` on `AgentExecutor` (stretch S3) |

## Done-when (Capstone 04 complete)

- [x] `search_course_docs` + `calculator` in prompt tool list
- [x] Math via calculator; RAG via search tool
- [x] REPL until `quit` / empty line
- [x] Explain ReAct vs RetrievalQA in one sentence

## See also

- [[langchain-react-agent-loop]]
- [[langchain-react-agent-executor]]
- [[rag-as-agent-tool]]
- [[langchain-agent-tool-input-sanitization]]
- [[rag-moc]]