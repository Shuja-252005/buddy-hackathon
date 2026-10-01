# Buddy — Project Specification

## What is Buddy?

Buddy is a mobile AI command center for developers.

The developer uses a Flutter mobile app to chat with an AI development team.

Instead of manually opening multiple terminals and giving different coding agents different instructions, the developer sends one high-level request.

For example:

> Fix the login bug and add the admin dashboard.

A locally running open-weight AI model acts as the **development team lead**.

It understands the request, breaks it into independent tasks, assigns those tasks to different coding agents, and runs them in separate Git worktrees.

The developer can then see the agents working and their results directly from the mobile app.

### Core idea

```text
Developer
    ↓
Flutter mobile app
    ↓
Python controller on Mac
    ↓
Open-weight model through Ollama
    ↓
Task planning / delegation
    ↓
Multiple coding agents
    ↓
Separate Git worktrees
    ↓
Progress + results
    ↓
Flutter mobile app
```

The main goal is to demonstrate that **one developer can coordinate multiple AI coding agents through a single mobile interface**.

---

# Hackathon Goal

This project is being built for an open-source / open-weight AI hackathon.

The open-weight model must be an important part of the application.

It should not simply be a chatbot added to the app.

The model is responsible for understanding developer requests and deciding how the work should be divided between coding agents.

The complete working pipeline is more important than having a large number of features.

---

# Main User Experience

The application should feel like a minimalist AI chat application designed for developers.

The developer opens the app and selects a project.

They type something like:

> Fix the authentication issue and update the admin dashboard.

The AI responds and explains that it has divided the request into multiple tasks.

For example:

```text
Task 1
agent-bugs
Fix authentication issue
Working...

Task 2
agent-admin
Update admin dashboard
Working...
```

The agents then work independently.

When an agent finishes, its result appears in the conversation.

For example:

```text
agent-bugs
✓ Completed

Authentication issue fixed.
Tests passed.
```

The developer should not need to manually manage the individual agents.

---

# Technology

## Mobile

Flutter / Dart.

The mobile app is the primary user interface.

## Mac Controller

Python.

A lightweight local server will run on the developer's Mac.

FastAPI can be used for the HTTP server.

## AI

Ollama running locally on the Mac.

An open-weight model will act as the AI team lead.

## Coding Agents

Use a CLI coding agent available on the Mac, preferably Codex CLI.

The exact CLI commands must be inspected before implementing the agent launcher.

Do not assume or invent CLI syntax.

## Communication

Flutter communicates with the Python server over the local Wi-Fi network.

The phone and Mac will be connected to the same network.

The Flutter application should communicate with the Mac using HTTP.

---

# Repository Structure

Everything related to Buddy must remain inside one GitHub repository.

The repository should have a simple structure similar to:

```text
Buddy/
│
├── lib/                    # Flutter application
├── android/
├── ios/
├── test/
│
├── server/
│   └── server.py          # Python controller
│
├── agents/                 # Optional agent configuration
│
├── PROJECT.md
├── README.md
├── LICENSE
└── pubspec.yaml
```

The Flutter application remains at the repository root.

The Python controller lives inside `server/`.

Do not create a separate Git repository for the Python server.

The external Git worktrees that Buddy controls are separate projects/directories on the Mac. They do not need to be inside this repository.

---

# Flutter Application

The Flutter application should be minimalist and chat-focused.

The design direction is:

* Black / dark theme
* Premium
* Modern
* Minimal
* Developer-focused
* Clean typography
* Subtle dark-gray surfaces
* Small amount of accent color
* Smooth and simple interaction

The app should feel more like a professional AI developer tool than a generic consumer application.

The main interaction should be the chat.

Avoid unnecessary dashboards and complicated navigation.

The application should allow the user to:

* Select a project
* Send a development request
* See the AI response
* See the tasks created by the AI
* See which agent is handling each task
* See agent status
* See results
* Optionally inspect useful agent output

The backend URL should be configurable from one location.

---

# Python Controller

The Python server is the bridge between the mobile app, Ollama, and coding agents.

Its responsibilities are:

1. Receive developer requests from Flutter.
2. Send the request to Ollama.
3. Ask the model to break the request into tasks.
4. Receive structured task information.
5. Determine the appropriate worktree for each task.
6. Launch coding agents.
7. Run multiple agents concurrently.
8. Track agent status.
9. Collect useful output.
10. Return status information to Flutter.

Keep this implementation simple.

A single `server.py` file is completely acceptable for the MVP.

Do not introduce unnecessary backend architecture.

Avoid:

* Database
* Authentication
* Cloud services
* Docker
* Microservices
* Complex message queues
* Unnecessary abstractions

---

# AI Planning

Ollama is the AI team lead.

The model should receive the developer's request and produce structured tasks.

Conceptually:

```text
Developer:

"Fix the login bug and update the admin dashboard."

                ↓

Open-weight model

                ↓

Tasks:

agent-bugs
→ Fix login bug

agent-admin
→ Update admin dashboard
```

The exact output format can be decided during implementation, but it must be structured enough for Python to reliably parse.

JSON is preferred.

The model should only create tasks that are actually relevant to the developer's request.

---

# Git Worktrees

Each coding agent works in its own Git worktree.

For example:

```text
agent-admin
    ↓
/path/to/play_slot_admin

agent-bugs
    ↓
/path/to/play_slot_bugfix

agent-ios
    ↓
/path/to/play_slot_ios
```

The worktree paths should be configurable.

Do not hard-code project-specific paths throughout the application.

Each agent process must start with its working directory set to the assigned worktree.

Agents must be isolated from each other.

Multiple agents should be able to run at the same time.

---

# Agent Execution

The Python controller should launch coding agents as separate processes.

Conceptually:

```text
Python Controller
       │
       ├── Agent 1 → worktree A
       │
       ├── Agent 2 → worktree B
       │
       └── Agent 3 → worktree C
```

They should run concurrently rather than waiting for one agent to finish before starting another.

Before implementing this functionality:

1. Inspect the installed coding-agent CLI.
2. Determine its correct non-interactive execution command.
3. Test one agent manually.
4. Then automate it from Python.
5. Then test multiple agents concurrently.

Never guess the CLI syntax.

---

# API

The initial API can be very small.

## GET /projects

Returns available projects and worktrees.

## POST /command

Receives a developer request.

Example:

```json
{
  "project": "PlaySlot",
  "prompt": "Fix the authentication bug and update the admin dashboard."
}
```

The server sends the prompt to the AI planner and starts the resulting tasks.

## GET /status

Returns the current status of agents and useful output.

Possible statuses include:

```text
Idle
Planning
Working
Completed
Failed
```

For the MVP, Flutter can poll the status endpoint every few seconds.

WebSockets are optional and should not delay the basic implementation.

---

# Example End-to-End Flow

The developer opens Buddy.

They select:

```text
PlaySlot
```

They send:

```text
Fix the Firestore permission problem and update the admin dashboard.
```

The Python controller sends the request to Ollama.

Ollama creates:

```text
Task 1
agent-bugs
Investigate and fix Firestore permissions.

Task 2
agent-admin
Update the admin dashboard.
```

The controller starts two coding agents:

```text
Codex
working directory → play_slot_bugfix

Codex
working directory → play_slot_admin
```

Both agents work at the same time.

Their status is returned to Flutter.

The user sees the progress inside the chat.

When they finish, their results are displayed.

---

# MVP Priority

The most important thing is to make this complete pipeline work:

```text
Flutter
   ↓
Python
   ↓
Ollama
   ↓
Task decomposition
   ↓
Multiple coding agents
   ↓
Separate Git worktrees
   ↓
Agent status
   ↓
Flutter
```

Everything else is secondary.

Do not spend large amounts of time on:

* Complex UI
* Authentication
* User accounts
* Databases
* Cloud deployment
* Advanced analytics
* Advanced agent memory
* Complex settings
* WebSockets

A simple working demonstration is more important.

---

# Development Strategy

Build incrementally.

### Phase 1

Finish the Flutter interface.

### Phase 2

Create the Python server.

### Phase 3

Connect Python to Ollama.

### Phase 4

Make Ollama produce structured task plans.

### Phase 5

Launch one coding agent from Python.

### Phase 6

Launch multiple coding agents concurrently.

### Phase 7

Connect Flutter to the server.

### Phase 8

Display live agent status/results.

### Phase 9

Test the complete demonstration.

---

# Important Instructions for Coding Agents

Before modifying the project:

* Read this `PROJECT.md`.
* Understand the overall architecture.
* Inspect the existing code.
* Do not unnecessarily rewrite working code.
* Keep the implementation simple.
* Do not introduce dependencies without a reason.
* Do not build features that are outside the MVP.
* Keep your changes focused on your assigned area.
* Make sure your code is easy for another agent to continue working on.

If working on the Flutter UI, do not implement the Python backend.

If working on the Python backend, do not redesign the Flutter UI.

If working on the AI planner, keep the planner interface clean so the backend can consume it.

---

# Definition of Done

Buddy is successful when the following demonstration works:

1. Open the Flutter app.
2. Connect to the Mac.
3. Select a project.
4. Send a natural-language coding request.
5. Ollama receives the request.
6. Ollama breaks the request into multiple tasks.
7. Python assigns the tasks to different worktrees.
8. Multiple coding agents start concurrently.
9. Agents work independently.
10. Agent status appears in the mobile app.
11. Agent results appear in the mobile app.

The key demonstration is:

> **One developer command → one AI team lead → multiple coding agents working in parallel.**
