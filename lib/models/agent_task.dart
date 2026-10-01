enum AgentStatus { queued, running, completed, failed }

extension AgentStatusLabel on AgentStatus {
  String get label => switch (this) {
    AgentStatus.queued => 'Queued',
    AgentStatus.running => 'Running',
    AgentStatus.completed => 'Completed',
    AgentStatus.failed => 'Failed',
  };

  static AgentStatus parse(Object? value) => switch (value) {
    'queued' => AgentStatus.queued,
    'running' => AgentStatus.running,
    'completed' => AgentStatus.completed,
    'failed' => AgentStatus.failed,
    _ => throw FormatException('Unknown agent status: $value'),
  };
}

class AgentTask {
  AgentTask({
    required this.id,
    required this.name,
    required this.title,
    required this.worktree,
    this.commandId = '',
    this.output = '',
    this.status = AgentStatus.queued,
    this.exitCode,
  });
  String id;
  final String name;
  final String title;
  final String worktree;
  final String commandId;
  String output;
  AgentStatus status;
  final int? exitCode;

  factory AgentTask.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Task response is missing "$key".');
      }
      return value;
    }

    return AgentTask(
      id: requiredString('id'),
      name: requiredString('worktree'),
      title: requiredString('task'),
      worktree: requiredString('worktree'),
      commandId: json['command_id'] is String
          ? json['command_id'] as String
          : '',
      output: json['output'] is String ? json['output'] as String : '',
      status: AgentStatusLabel.parse(json['status']),
      exitCode: json['exit_code'] is int ? json['exit_code'] as int : null,
    );
  }
}

class Exchange {
  Exchange({
    required this.id,
    required this.message,
    required this.reply,
    required this.tasks,
    this.isPlanning = false,
    this.isSending = false,
  });
  String id;
  final String message;
  String reply;
  final List<AgentTask> tasks;
  bool isPlanning;
  bool isSending;
}
