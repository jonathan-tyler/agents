---
name: voice-input-typos
description: Normalize common voice-input transcription mistakes for developer terms and commands.
metadata:
  author: jonathan-tyler
  version: "1.0.0"
---

# Voice Input Typos Skill

## Rules

- Interpret common voice transcription variants for coding terms before acting on requests.
- Apply these normalizations when intent is clear:
  - `a` → `AA`
  - `cache` ↔ `cash`
  - `git config` ↔ `get config`, `get conflict`
  - `git switch` ↔ `get switch`, `get switched`
  - `git` ↔ `get`
  - `gitignore` ↔ `get ignore`, `get ignored`
  - `JSON` ↔ `jason`
  - `LLM` ↔ `LOL`
  - `vi` ↔ `the eye`
- If a transcript remains ambiguous after normalization, ask a short clarification question.
