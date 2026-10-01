part of '../main.dart';

enum AgentStatus { working, completed, stopped }

class AgentTask {
  AgentTask({
    required this.id,
    required this.name,
    required this.title,
    required this.worktree,
    required this.result,
    this.step = 0,
    this.status = AgentStatus.working,
  });
  final String id;
  final String name;
  final String title;
  final String worktree;
  final String result;
  int step;
  AgentStatus status;
}

class Exchange {
  Exchange({
    required this.id,
    required this.message,
    required this.reply,
    required this.tasks,
  });
  final int id;
  final String message;
  final String reply;
  final List<AgentTask> tasks;
}
