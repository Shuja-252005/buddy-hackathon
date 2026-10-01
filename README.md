# Buddy

Buddy is a Flutter mobile command center for delegating development work to AI agents. It follows the supplied AgentFlow design, with PlaySlot as the sample project. The Python controller in `server/` uses the local Ollama model as its planner and Codex CLI for isolated worktree agents.

## Run locally

```sh
flutter pub get
flutter run
```

## Project structure

- `lib/` — Flutter application source
- `test/` — Flutter tests
- `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/` — platform runners
- `.github/workflows/` — GitHub Actions checks
- `PROJECT.md` — end-to-end product specification and architecture
- `server/server.py` — local FastAPI controller

## Server handoff

Install and start the local controller from the repository root:

```sh
python3 -m venv server/.venv
server/.venv/bin/pip install -r server/requirements.txt
cd server
BUDDY_OLLAMA_MODEL=gemma4:e4b .venv/bin/uvicorn server:app --host 0.0.0.0 --port 8000
```

The Flutter server URL is configurable with `--dart-define=BUDDY_SERVER_URL=http://<mac-lan-ip>:8000`. The Android emulator defaults to `http://10.0.2.2:8000`; for a physical phone, use the Mac's Wi-Fi/LAN IP, for example `flutter run --dart-define=BUDDY_SERVER_URL=http://192.168.1.20:8000`.

Project worktrees are configured together at the top of `server/server.py`. Defaults point to the existing local PlaySlot worktrees. `BUDDY_PLAY_SLOT_ROOT`, `BUDDY_PLAY_SLOT_AGENT_ADMIN_WORKTREE`, `BUDDY_PLAY_SLOT_AGENT_BUGS_WORKTREE`, and `BUDDY_PLAY_SLOT_AGENT_IOS_WORKTREE` can override those locations.

The planned HTTP contract is defined in `PROJECT.md`:

- `GET /projects` — available projects and worktrees
- `POST /command` — `{ "project": "PlaySlot", "command": "..." }`
- `GET /status` — planning/agent statuses and useful output

Ollama defaults to `http://127.0.0.1:11434` and model `gemma4:e4b`; configure these with `BUDDY_OLLAMA_URL` and `BUDDY_OLLAMA_MODEL`. Codex uses its installed CLI and defaults to `danger-full-access`; `BUDDY_CODEX_TIMEOUT_SECONDS` configures its execution timeout.

## Git workflow

The default branch is `main`. Create a feature branch for changes and open a pull request before merging. Commit messages should describe the change, for example `Build Buddy agent flow interface`.
