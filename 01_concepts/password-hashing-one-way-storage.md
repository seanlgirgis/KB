---
title: Password Hashing — Why Servers Cannot Store or Remind Passwords
tags:
  - python
  - security
  - passwords
  - hashing
  - cryptography
topics:
  - software-engineering
  - security
status: curated
created: 2026-06-18
updated: 2026-06-18
related:
  - "[[python-hashlib-sha256-fingerprints]]"
  - "[[software-engineering-moc]]"
source:
---

# Password Hashing — Why Servers Cannot Store or Remind Passwords

Well-designed systems **never store your actual password**. They store a **one-way hash** (plus salt and algorithm parameters) so login can verify “same password” without ever keeping reversible secrets. That is why a secure site can reset access but **cannot email you your old password** — it never had the plaintext.

## Core idea

Password storage is not “hide the password in the database.” It is **prove the user typed the same secret again** by hashing the attempt and comparing to the stored hash.

1. **Signup or password change** — user enters password → system hashes with salt → stores hash + salt + params only.
2. **Login** — user enters password → system hashes with the **same salt** → compares to stored hash → match means success.

The server is **blind** to the real password after signup. Hashing is one-way: there is no reliable inverse from hash back to password.

## Why systems cannot remind you of your password

They **do not have it** — only the hash (and salt). Intentional design: a database leak should not hand attackers a list of login passwords.

**Red flag:** any site that can “show” or “email your current password” is storing plaintext or reversible encryption treated like plaintext.

## Password history (old hashes)

On password change, many systems keep **previous password hashes** (often last 5–10):

- New password is hashed and compared against old hashes.
- If it matches any prior hash → reject (“cannot reuse previous password”).

Still only hashes in storage — never historical plaintext.

## Strong storage vs bare SHA-256

General fingerprints use [[python-hashlib-sha256-fingerprints]] (`hashlib.sha256()` on file bytes). **Passwords need more:**

| Mechanism | Role |
|-----------|------|
| **Salt** | Random per-user bytes so identical passwords hash differently |
| **Slow KDF** | `PBKDF2`, `bcrypt`, or `Argon2` — makes guessing attacks expensive |
| **High work factor** | Tune cost so logins stay fast for users, guessing stays slow for attackers |

Bare `sha256(password)` without salt is **not** acceptable for password storage.

## Example (PBKDF2 with hashlib)

Illustrative — production apps should use vetted libraries (`passlib`, framework auth) with current defaults.

```python
import hashlib
import os

ITERATIONS = 600_000  # tune to policy; increase over time


def hash_password(password: str) -> bytes:
    """Returns salt (16 bytes) + derived key — store as one blob or separate fields."""
    salt = os.urandom(16)
    derived = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        ITERATIONS,
    )
    return salt + derived


def verify_password(password: str, stored: bytes) -> bool:
    salt, expected = stored[:16], stored[16:]
    derived = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        ITERATIONS,
    )
    return derived == expected
```

Prefer **`bcrypt`** or **`argon2`** when the stack allows — they bundle salt and cost parameters in standard formats.

## Key takeaways

- Good systems **never** store plaintext passwords.
- Stolen hash DB still hurts — attackers offline-guess weak passwords — but salting + slow KDF raises cost sharply.
- Password reset issues a **new** credential flow; it does not “look up” the old password.
- Content dedupe hashes (RAG manifests) and password hashes share `hashlib` but **different algorithms and threat models**.

## See also

- [[python-hashlib-sha256-fingerprints]] — SHA-256 for files, bytes, and manifest fingerprints
- [[software-engineering-moc]]