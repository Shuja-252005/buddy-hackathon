"""Buddy's local controller for Ollama planning and concurrent Codex agents."""

from __future__ import annotations

import asyncio
import json
import logging
import os
import signal
import tempfile
import uuid
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, field_validator


logging.basicConfig(level=os.getenv("BUDDY_LOG_LEVEL", "INFO"))
logger = logging.getLogger("buddy.server")

# Edit this map to add projects or point agent roles at different existing
# worktrees. Each environment variable can override its corresponding path.
_PLAY_SLOT_ROOT = Path(
    os.getenv(
        "BUDDY_PLAY_SLOT_ROOT",
        str(Path.home() / "Documents/Shuja/Flutter Projects"),
    )
).expanduser()
PROJECTS: dict[str, dict[str, dict[str, Path]]] = {
    "PlaySlot": {
        "worktrees": {
            "agent-admin": Path(
                os.getenv(
                    "BUDDY_PLAY_SLOT_AGENT_ADMIN_WORKTREE",
                    str(_PLAY_SLOT_ROOT / "play_slot_app"),
                )
            ).expanduser(),
            "agent-bugs": Path(
                os.getenv(
                    "BUDDY_PLAY_SLOT_AGENT_BUGS_WORKTREE",
                    str(_PLAY_SLOT_ROOT / "play_slot_bugfix"),
                )
            ).expanduser(),
            "agent-ios": Path(
                os.getenv(
                    "BUDDY_PLAY_SLOT_AGENT_IOS_WORKTREE",
                    str(_PLAY_SLOT_ROOT / "iphone"),
                )
            ).expanduser(),
        }
    }
}

OLLAMA_URL = os.getenv("BUDDY_OLLAMA_URL", "http://127.0.0.1:11434").rstrip("/")
OLLAMA_MODEL = os.getenv("BUDDY_OLLAMA_MODEL", "gemma4:e4b")
OLLAMA_TIMEOUT_SECONDS = float(os.getenv("BUDDY_OLLAMA_TIMEOUT_SECONDS", "180"))
CODEX_BIN = os.getenv("BUDDY_CODEX_BIN", "codex")
CODEX_TIMEOUT_SECONDS = float(os.getenv("BUDDY_CODEX_TIMEOUT_SECONDS", "1800"))
CODEX_SANDBOX = os.getenv("BUDDY_CODEX_SANDBOX", "danger-full-access")
MAX_CAPTURED_OUTPUT = 24_000
VALID_CODEX_SANDBOXES = {"read-only", "workspace-write", "danger-full-access"}

if CODEX_SANDBOX not in VALID_CODEX_SANDBOXES:
    raise RuntimeError(
        "BUDDY_CODEX_SANDBOX must be read-only, workspace-write, or danger-full-access"
    )

app = FastAPI(
    title="Buddy local controller",
    description="Local Ollama task planning and concurrent Codex worktree agents.",
    version="0.1.0",
)


class CommandRequest(BaseModel):
    project: str = Field(min_length=1, max_length=120)
    command: str = Field(min_length=1, max_length=20_000)


class PlannedTask(BaseModel):
    worktree: str = Field(min_length=1, max_length=120)
    task: str = Field(min_length=1, max_length=8_000)

    @field_validator("worktree", "task")
    @classmethod
    def strip_nonblank_values(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("must not be blank")
        return value


def _now() -> str:
    return datetime.now(UTC).isoformat()


def _worktree_error(path: Path) -> str | None:
    if not path.exists():
        return "configured worktree directory does not exist"
    if not path.is_dir():
        return "configured worktree path is not a directory"
    if not (path / ".git").exists():
        return "configured directory is not a Git worktree (missing .git)"
    return None


async def _is_git_worktree(path: Path) -> bool:
    """Confirm the configured directory is the root of a Git worktree."""
    try:
        process = await asyncio.create_subprocess_exec(
            "git",
            "-C",
            str(path),
            "rev-parse",
            "--show-toplevel",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, _ = await asyncio.wait_for(process.communicate(), timeout=5)
    except (OSError, TimeoutError):
        return False
    if process.returncode != 0:
        return False
    try:
        return Path(stdout.decode().strip()).resolve() == path.resolve()
    except OSError:
        return False


async def _inspect_worktree(path: Path) -> tuple[bool, str | None]:
    error = _worktree_error(path)
    if error:
        return False, error
    if not await _is_git_worktree(path):
        return False, "configured directory is not a Git worktree root"
    return True, None


async def _project_worktree_availability(
    worktrees: dict[str, Path],
) -> dict[str, tuple[bool, str | None]]:
    availability: dict[str, tuple[bool, str | None]] = {}
    claimed_paths: dict[Path, str] = {}
    for name, path in worktrees.items():
        valid, reason = await _inspect_worktree(path)
        if valid:
            canonical_path = path.resolve()
            previous_name = claimed_paths.get(canonical_path)
            if previous_name:
                valid = False
                reason = f"same directory is already assigned to {previous_name}"
            else:
                claimed_paths[canonical_path] = name
        availability[name] = (valid, reason)
    return availability


async def _available_worktrees(project: str) -> dict[str, Path]:
    project_config = PROJECTS.get(project)
    if project_config is None:
        raise HTTPException(status_code=404, detail=f"Unknown project: {project}")

    availability = await _project_worktree_availability(project_config["worktrees"])
    available: dict[str, Path] = {}
    for name, path in project_config["worktrees"].items():
        valid, _ = availability[name]
        if valid:
            available[name] = path
    if not available:
        raise HTTPException(
            status_code=503,
            detail=f"Project {project} has no configured, available Git worktrees.",
        )
    return available


def _planner_system_prompt(project: str, worktree_names: list[str]) -> str:
    return f"""You are the technical team lead for Buddy, a local AI development command center.
Analyze a developer's request and split it into the smallest useful set of independent coding tasks.
Assign each task to one suitable existing worktree from the allowed list. Tasks assigned to different worktrees will run concurrently, so only split work when the tasks can safely proceed independently. Never assign two tasks to the same worktree. Do not invent worktrees, paths, agent names, or unrelated work. If the request is one cohesive task, return one task.
Never return an empty task list. Inspection, explanation, and read-only audit requests are valid tasks too; preserve any instruction not to modify files in the task description and assign the single task to one suitable worktree.

Project: {project}
Allowed worktree names: {json.dumps(worktree_names)}

Return ONLY valid JSON with this exact shape:
{{"tasks":[{{"worktree":"agent-bugs","task":"Investigate and fix the issue"}}]}}
Do not use markdown fences or add text outside the JSON object."""


def _parse_planner_content(content: str, allowed_worktrees: set[str]) -> list[PlannedTask]:
    try:
        decoded: Any = json.loads(content)
    except json.JSONDecodeError:
        # Recover a JSON object if a model prepends a short explanation despite
        # the JSON-only instruction, while still rejecting malformed output.
        first = content.find("{")
        last = content.rfind("}")
        if first < 0 or last <= first:
            raise HTTPException(
                status_code=502,
                detail="Ollama returned malformed task-plan JSON.",
            )
        try:
            decoded = json.loads(content[first : last + 1])
        except json.JSONDecodeError as error:
            raise HTTPException(
                status_code=502,
                detail=f"Ollama returned malformed task-plan JSON: {error.msg}.",
            ) from error

    if not isinstance(decoded, dict) or not isinstance(decoded.get("tasks"), list):
        raise HTTPException(
            status_code=502,
            detail='Ollama plan must be a JSON object with a "tasks" array.',
        )
    if not decoded["tasks"]:
        raise HTTPException(status_code=502, detail="Ollama returned an empty task plan.")
    if len(decoded["tasks"]) > len(allowed_worktrees):
        raise HTTPException(
            status_code=502,
            detail="Ollama returned more tasks than available independent worktrees.",
        )

    tasks: list[PlannedTask] = []
    used_worktrees: set[str] = set()
    for index, raw_task in enumerate(decoded["tasks"]):
        try:
            task = PlannedTask.model_validate(raw_task)
        except Exception as error:
            raise HTTPException(
                status_code=502,
                detail=f"Ollama task {index + 1} is invalid: {error}.",
            ) from error
        if task.worktree not in allowed_worktrees:
            raise HTTPException(
                status_code=502,
                detail=f"Ollama selected unknown worktree: {task.worktree}.",
            )
        if task.worktree in used_worktrees:
            raise HTTPException(
                status_code=502,
                detail=f"Ollama assigned multiple concurrent tasks to {task.worktree}.",
            )
        used_worktrees.add(task.worktree)
        tasks.append(task)
    return tasks


async def _plan_tasks(project: str, command: str, worktrees: dict[str, Path]) -> list[PlannedTask]:
    payload = {
        "model": OLLAMA_MODEL,
        "stream": False,
        "format": "json",
        "messages": [
            {"role": "system", "content": _planner_system_prompt(project, list(worktrees))},
            {"role": "user", "content": command},
        ],
        "options": {"temperature": 0.1, "num_predict": 384},
    }
    try:
        async with httpx.AsyncClient(timeout=OLLAMA_TIMEOUT_SECONDS) as client:
            response = await client.post(f"{OLLAMA_URL}/api/chat", json=payload)
            response.raise_for_status()
    except httpx.TimeoutException as error:
        raise HTTPException(
            status_code=504,
            detail=f"Ollama planning timed out after {OLLAMA_TIMEOUT_SECONDS:g} seconds.",
        ) from error
    except httpx.HTTPStatusError as error:
        message = error.response.text[:500]
        raise HTTPException(
            status_code=502,
            detail=f"Ollama returned HTTP {error.response.status_code}: {message}",
        ) from error
    except httpx.RequestError as error:
        raise HTTPException(
            status_code=503,
            detail=f"Ollama is unavailable at {OLLAMA_URL}: {error}.",
        ) from error

    try:
        body = response.json()
        content = body["message"]["content"]
    except (ValueError, KeyError, TypeError) as error:
        raise HTTPException(
            status_code=502,
            detail="Ollama returned an unexpected response; expected message.content.",
        ) from error
    if not isinstance(content, str):
        raise HTTPException(status_code=502, detail="Ollama task-plan content was not text.")
    return _parse_planner_content(content, set(worktrees))


def _codex_output_from_jsonl(stdout: str) -> str:
    useful: list[str] = []
    fallback: list[str] = []
    for line in stdout.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            if line.strip():
                fallback.append(line.strip())
            continue
        event_type = event.get("type") if isinstance(event, dict) else None
        item = event.get("item") if isinstance(event, dict) else None
        if event_type == "item.completed" and isinstance(item, dict):
            if item.get("type") == "agent_message" and isinstance(item.get("text"), str):
                useful.append(item["text"].strip())
            elif item.get("type") == "command_execution":
                command = item.get("command", "command")
                output = item.get("aggregated_output", "")
                if output:
                    useful.append(f"$ {command}\n{str(output)[-4_000:]}")
        elif event_type in {"turn.failed", "error"}:
            useful.append(json.dumps(event, ensure_ascii=False))
    return "\n\n".join(useful or fallback).strip()


def _append_output(existing: str, addition: str) -> str:
    addition = addition.strip()
    if not addition:
        return existing[-MAX_CAPTURED_OUTPUT:]
    combined = f"{existing}\n\n{addition}".strip() if existing else addition
    return combined[-MAX_CAPTURED_OUTPUT:]


commands: dict[str, dict[str, Any]] = {}
agent_tasks: dict[str, dict[str, Any]] = {}
_state_lock = asyncio.Lock()
_agent_runners: set[asyncio.Task[None]] = set()


def _refresh_command_status(command_id: str) -> None:
    record = commands[command_id]
    task_ids = record["task_ids"]
    if not task_ids:
        return
    task_records = [agent_tasks[task_id] for task_id in task_ids]
    if not all(task["status"] in {"completed", "failed"} for task in task_records):
        record["status"] = "working"
        return
    record["status"] = (
        "completed" if all(task["status"] == "completed" for task in task_records) else "failed"
    )
    record["completed_at"] = _now()


async def _run_agent(task_id: str, command_id: str, worktree_path: Path) -> None:
    task_record = agent_tasks[task_id]
    task_record["status"] = "running"
    task_record["started_at"] = _now()
    task_record["output"] = "Starting Codex..."

    output_path: str | None = None
    process: asyncio.subprocess.Process | None = None
    try:
        with tempfile.NamedTemporaryFile(prefix="buddy-codex-", suffix=".txt", delete=False) as output_file:
            output_path = output_file.name
        command = [
            CODEX_BIN,
            "exec",
            "--cd",
            str(worktree_path),
            "--sandbox",
            CODEX_SANDBOX,
            "--json",
            "--output-last-message",
            output_path,
            task_record["task"],
        ]
        logger.info("Launching %s in %s", task_id, worktree_path)
        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            start_new_session=(os.name == "posix"),
        )
        try:
            stdout_bytes, stderr_bytes = await asyncio.wait_for(
                process.communicate(), timeout=CODEX_TIMEOUT_SECONDS
            )
        except TimeoutError:
            if os.name == "posix":
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            else:
                process.kill()
            stdout_bytes, stderr_bytes = await process.communicate()
            task_record["output"] = _append_output(
                _codex_output_from_jsonl(stdout_bytes.decode(errors="replace")),
                f"Codex timed out after {CODEX_TIMEOUT_SECONDS:g} seconds.",
            )
            if stderr_bytes:
                task_record["output"] = _append_output(
                    task_record["output"], stderr_bytes.decode(errors="replace")
                )
            task_record["status"] = "failed"
            task_record["exit_code"] = process.returncode
            return

        stdout_text = stdout_bytes.decode(errors="replace")
        stderr_text = stderr_bytes.decode(errors="replace")
        parsed_output = _codex_output_from_jsonl(stdout_text)
        final_message = Path(output_path).read_text(errors="replace").strip()
        task_record["output"] = final_message or parsed_output or stdout_text.strip()
        if stderr_text:
            task_record["output"] = _append_output(task_record["output"], stderr_text)
        task_record["exit_code"] = process.returncode
        task_record["status"] = "completed" if process.returncode == 0 else "failed"
        if process.returncode != 0 and not task_record["output"]:
            task_record["output"] = f"Codex exited with code {process.returncode}."
    except FileNotFoundError:
        task_record["status"] = "failed"
        task_record["output"] = f"Codex executable was not found: {CODEX_BIN}."
    except OSError as error:
        task_record["status"] = "failed"
        task_record["output"] = f"Could not start Codex: {error}"
    except Exception as error:  # Keep an agent failure visible instead of losing its state.
        logger.exception("Unexpected error while running %s", task_id)
        task_record["status"] = "failed"
        task_record["output"] = f"Codex runner error: {error}"
    finally:
        task_record["completed_at"] = _now()
        if output_path:
            try:
                Path(output_path).unlink(missing_ok=True)
            except OSError:
                logger.warning("Could not remove Codex output file %s", output_path)
        _refresh_command_status(command_id)


def _track_runner(task: asyncio.Task[None]) -> None:
    _agent_runners.add(task)
    task.add_done_callback(_agent_runners.discard)


@app.get("/projects")
async def get_projects() -> dict[str, list[dict[str, Any]]]:
    result: list[dict[str, Any]] = []
    for project_name, project_config in PROJECTS.items():
        worktrees: list[dict[str, Any]] = []
        availability = await _project_worktree_availability(project_config["worktrees"])
        for name, path in project_config["worktrees"].items():
            available, reason = availability[name]
            worktrees.append(
                {
                    "name": name,
                    "path": str(path),
                    "available": available,
                    "reason": reason,
                }
            )
        result.append({"name": project_name, "worktrees": worktrees})
    return {"projects": result}


@app.post("/command", status_code=202)
async def post_command(request: CommandRequest) -> dict[str, Any]:
    project_name = request.project.strip()
    command_text = request.command.strip()
    if not command_text:
        raise HTTPException(status_code=422, detail="command must not be blank")

    command_id = str(uuid.uuid4())
    record = {
        "id": command_id,
        "project": project_name,
        "command": command_text,
        "status": "planning",
        "task_ids": [],
        "error": None,
        "created_at": _now(),
        "completed_at": None,
    }
    async with _state_lock:
        commands[command_id] = record

    try:
        worktrees = await _available_worktrees(project_name)
        planned_tasks = await _plan_tasks(project_name, command_text, worktrees)
        for task in planned_tasks:
            path = worktrees[task.worktree]
            available, reason = await _inspect_worktree(path)
            if not available:
                raise HTTPException(
                    status_code=503,
                    detail=f"Worktree {task.worktree} became unavailable: {reason}.",
                )

        response_tasks: list[dict[str, Any]] = []
        async with _state_lock:
            for task in planned_tasks:
                task_id = str(uuid.uuid4())
                task_record = {
                    "id": task_id,
                    "project": project_name,
                    "worktree": task.worktree,
                    "task": task.task,
                    "status": "queued",
                    "output": "",
                    "started_at": None,
                    "completed_at": None,
                    "exit_code": None,
                    "command_id": command_id,
                }
                agent_tasks[task_id] = task_record
                response_tasks.append(dict(task_record))
                record["task_ids"].append(task_id)
            record["status"] = "working"

        # Schedule all worktree agents before returning so independent tasks
        # can run at the same time.
        for task_record in response_tasks:
            runner = asyncio.create_task(
                _run_agent(
                    task_record["id"],
                    command_id,
                    worktrees[task_record["worktree"]],
                ),
                name=f"buddy-agent-{task_record['id']}",
            )
            _track_runner(runner)
        return {
            "command_id": command_id,
            "project": project_name,
            "status": "working",
            "tasks": response_tasks,
        }
    except HTTPException as error:
        async with _state_lock:
            record["status"] = "failed"
            record["error"] = error.detail
            record["completed_at"] = _now()
        raise


@app.get("/status")
async def get_status() -> dict[str, list[dict[str, Any]]]:
    async with _state_lock:
        return {
            "commands": [dict(command) for command in commands.values()],
            "tasks": [dict(task) for task in agent_tasks.values()],
        }
