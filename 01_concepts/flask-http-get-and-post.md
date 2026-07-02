---
title: Flask HTTP GET and POST
tags:
  - flask
  - http
  - web
  - python
topics:
  - software-engineering
status: curated
created: 2026-06-19
updated: 2026-06-19
related:
  - "[[agentic-rag-web-service-stack]]"
  - "[[python-urllib-urls-and-fetching]]"
  - "[[python-json-read-write-files]]"
  - "[[software-engineering-moc]]"
source: Sean study question (Flask routes)
---

# Flask HTTP GET and POST

**GET** and **POST** are **HTTP methods** — they tell the server what kind of request the client is making. In **Flask**, you declare which methods a route accepts with `@app.route(..., methods=[...])` and read data from `request` differently per method.

**Layman:** **GET** = “show me this page.” **POST** = “here’s what I submitted — process it.”

## GET — read / fetch

| Aspect | GET |
|--------|-----|
| **Purpose** | Load a page, search, fetch data — should not change server state (by convention) |
| **Where data lives** | URL — path or query string (`?name=Sean`) |
| **Repeat / bookmark** | Safe to refresh or bookmark |
| **Flask access** | `request.args` (query params), `request.method == "GET"` |

```python
from flask import Flask, request

app = Flask(__name__)

@app.route("/hello")
def hello():
    name = request.args.get("name", "world")
    return f"Hello, {name}!"
```

`GET /hello?name=Sean` → reads `name` from the query string.

**Default:** `@app.route("/page")` with no `methods=` accepts **GET only**.

## POST — submit / create / update

| Aspect | POST |
|--------|-----|
| **Purpose** | Send data to the server — forms, logins, creates/updates |
| **Where data lives** | **Request body** (form fields, JSON), not mainly the URL |
| **Repeat / bookmark** | Re-submitting can duplicate actions (e.g. double charge) |
| **Flask access** | `request.form` (HTML forms), `request.get_json()` (JSON APIs) |

```python
@app.route("/login", methods=["POST"])
def login():
    username = request.form.get("username")
    password = request.form.get("password")
    # validate, session, redirect...
    return "Logged in"
```

HTML: `<form method="post" action="/login">` triggers **POST**.

## Same URL, two methods

Common pattern: **GET** shows the form; **POST** handles submit.

```python
@app.route("/contact", methods=["GET", "POST"])
def contact():
    if request.method == "POST":
        message = request.form.get("message")
        # save or email...
        return "Thanks!"
    return render_template("contact.html")
```

## GET vs POST (quick table)

| | GET | POST |
|--|-----|------|
| Intent | Read | Submit / write |
| Data | URL query | Body |
| Size | Small (URL limits) | Larger payloads OK |
| Idempotent? | Yes (ideal) | No — repeats may re-apply |

## Client vs server

Flask is the **server** side. When *your Python script* calls an API, **GET/POST** use `urllib` or `requests` — see [[python-urllib-urls-and-fetching]]. JSON bodies on POST pair with [[python-json-read-write-files]].

## See also

- [[agentic-rag-web-service-stack]] — Flask/FastAPI in full RAG/agent deployment
- [[python-urllib-urls-and-fetching]] — GET/POST from the client with `urllib.request`
- [[software-engineering-moc]]