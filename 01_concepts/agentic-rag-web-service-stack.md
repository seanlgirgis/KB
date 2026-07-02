---
title: Agentic and RAG Web Service Stack
tags:
  - rag
  - agents
  - http
  - api
  - fastapi
  - flask
  - langchain
  - deployment
topics:
  - retrieval
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[flask-http-get-and-post]]"
  - "[[rag-ingest-chat-two-script-architecture]]"
  - "[[langchain-agent-patterns-overview]]"
  - "[[langchain-rag-chains-overview]]"
  - "[[fixed-pipeline-vs-langchain-agent]]"
  - "[[pluggable-embedding-models]]"
  - "[[chroma-persist-append-and-reingest]]"
  - "[[software-engineering-moc]]"
  - "[[rag-moc]]"
source: Sean paste — Python Agentic AI / RAG as HTTP APIs
---
Fas
# Agentic and RAG Web Service Stack

Python **agent** and **RAG** workflows are usually **CLI scripts or notebooks** during learning ([[rag-ingest-chat-two-script-architecture]]). In production they are exposed as **HTTP URLs** — a web framework or AI-serving layer sits in front of LangChain/LlamaIndex logic, vector DB, and the LLM.

**Layman:** your capstone chat script becomes a website endpoint — browsers or apps `POST` a question; the server runs retrieve/agent logic and returns JSON.

## Typical production stack

```text
Client (browser, app, curl)
    ↓ HTTP
FastAPI (most common) or Flask
    ↓
LangChain / LlamaIndex / CrewAI
    ↓
Vector DB (Chroma, Pinecone, Weaviate, Qdrant)
    ↓
LLM (OpenAI, Watsonx, Ollama, vLLM)
```

Common endpoints:

```http
POST /chat
POST /agent
POST /rag/query
POST /search
POST /stream
```

**2025–2026 default combo:** FastAPI + LangChain or LlamaIndex + Ollama or vLLM + Docker/Kubernetes. FastAPI is the layer that **owns the public URL**.

## Layer 1 — Web frameworks (HTTP → Python)

Turn Python callables into routes. See [[flask-http-get-and-post]] for GET vs POST on the server.

| Framework | Role | AI fit |
|-----------|------|--------|
| **FastAPI** | Async, OpenAPI/Swagger auto-docs, high throughput | **Most popular** for LLM/RAG APIs |
| **Flask** | Lightweight, sync-first | Smaller services, learning, prototypes |
| **Django** | Full web app stack | AI feature inside larger product |

**FastAPI sketch:**

```python
from fastapi import FastAPI

app = FastAPI()

@app.post("/chat")
async def chat(request: dict):
    return {"response": "hello"}
```

**Flask sketch:**

```python
from flask import Flask, request

app = Flask(__name__)

@app.route("/chat", methods=["POST"])
def chat():
    body = request.get_json()
    return {"response": "hello"}
```

## Layer 2 — AI-specific serving (chains as REST)

Wrap existing LangChain/LlamaIndex/Haystack pipelines without hand-writing every route.

| Tool | What it exposes |
|------|-----------------|
| **LangServe** | LangChain chains, agents, RAG as REST — `add_routes(app, chain, path="/rag")` |
| **LlamaIndex Server** | LlamaIndex RAG workflows |
| **Haystack** | Search + RAG pipelines with REST support |

**LangServe** auto-routes such as:

```text
POST /rag/invoke
POST /rag/stream
POST /rag/batch
```

Use when the app is already LangChain-shaped — [[langchain-rag-chains-overview]], [[langchain-agent-patterns-overview]].

## Layer 3 — Model serving (LLM over HTTP)

Hosts the **model** behind OpenAI-style or vendor-specific APIs — separate from your RAG app or behind it.

| Platform | Example endpoints |
|----------|-------------------|
| **vLLM** | `POST /v1/chat/completions`, `POST /v1/completions` |
| **Text Generation Inference (TGI)** | Production OSS LLM serving |
| **Ollama** | `http://localhost:11434/api/generate` |
| **Ray Serve** | Large-scale multi-model / agent deployments |

Your FastAPI app often **calls** these as the LLM backend while owning `/rag/query` and `/agent`.

## Layer 4 — Agent frameworks behind the API

Frameworks rarely ship a public URL alone — they are wired **inside** FastAPI/Flask.

```text
Client → FastAPI → LangChain Agent → tools + RAG
```

| Framework | Typical API wrapper |
|-----------|---------------------|
| **LangChain** | FastAPI or LangServe |
| **AutoGen** | FastAPI or custom REST |
| **CrewAI** | FastAPI |

Fixed RAG vs agent routing: [[fixed-pipeline-vs-langchain-agent]]. Capstone CLI shape: [[langchain-research-agent-repl]].

## Layer 5 — Gateways and edge

After the Python process listens on a port, ops often front it with:

```text
Internet → Nginx / Traefik / Kong → FastAPI → Agent/RAG
```

TLS termination, rate limits, auth, load balancing — not Python-specific but standard in production.

## Layer 6 — Serverless URLs

Same workflows without long-lived servers:

- AWS Lambda + API Gateway
- Google Cloud Functions
- Azure Functions

Good for bursty or low-traffic wrappers; cold start and timeout limits matter for long LLM streams.

## Mapping to your capstone scripts

| Capstone style | Web equivalent |
|----------------|----------------|
| `ingest.py` (batch ETL) | Admin/cron job or `POST /ingest` (often internal) |
| `chat.py` (RetrievalQA REPL) | `POST /rag/query` |
| Research agent REPL | `POST /agent` or `/chat` with agent executor |
| Shared `config` module | Same module imported by FastAPI routes |

Ingest still uses [[rag-ingest-pipeline-spine]] + [[chroma-persist-append-and-reingest]]; query path uses [[pluggable-embedding-models]] parity at serve time.

## Choosing a wrapper

| Situation | Start with |
|-----------|------------|
| New production RAG API | **FastAPI** + your chain |
| Already LangChain + want routes fast | **LangServe** on FastAPI |
| Teaching HTTP basics | **Flask** — [[flask-http-get-and-post]] |
| Self-hosted model only | **Ollama** or **vLLM** HTTP, app calls it |
| Multi-agent at scale | Framework + **Ray Serve** or K8s replicas |

## See also

- [[flask-http-get-and-post]] — GET/POST on Flask routes
- [[python-urllib-urls-and-fetching]] — client-side HTTP from Python
- [[python-json-read-write-files]] — JSON request/response bodies
- [[rag-ingest-chat-two-script-architecture]] — CLI precursor to HTTP split
- [[langchain-agent-patterns-overview]] — agent patterns behind `/agent`
- [[rag-moc]]
- [[software-engineering-moc]]