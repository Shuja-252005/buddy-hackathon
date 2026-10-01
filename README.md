# Buddy

Buddy is a Flutter mobile command center for delegating development work to AI agents. It follows the supplied AgentFlow design, with PlaySlot as the sample project. The current task conversation is preview data; the Python controller and Ollama integration are separate follow-on work.

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

## Server handoff

Keep the Python controller in `server/server.py` in this repository. The Flutter server URL has one configuration point in `lib/config/api_config.dart`; pass a Mac LAN URL at launch with `--dart-define=BUDDY_SERVER_URL=http://<mac-lan-ip>:8000`.

The planned HTTP contract is defined in `PROJECT.md`:

- `GET /projects` — available projects and worktrees
- `POST /command` — `{ "project": "PlaySlot", "prompt": "..." }`
- `GET /status` — planning/agent statuses and useful output

The Flutter UI currently shows preview state and does not send network requests. The next integration step can replace that preview data with the API responses without adding server code to the Flutter layer.

## Git workflow

The default branch is `main`. Create a feature branch for changes and open a pull request before merging. Commit messages should describe the change, for example `Build Buddy agent flow interface`.
