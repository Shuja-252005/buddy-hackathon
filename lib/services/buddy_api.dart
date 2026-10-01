import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/agent_task.dart';

class BuddyProject {
  const BuddyProject({required this.name, required this.worktrees});

  final String name;
  final List<BuddyWorktree> worktrees;

  int get availableWorktreeCount => worktrees.where((w) => w.available).length;

  factory BuddyProject.fromJson(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['name'] is! String ||
        value['worktrees'] is! List) {
      throw const FormatException('Project response has an invalid shape.');
    }
    return BuddyProject(
      name: value['name'] as String,
      worktrees: (value['worktrees'] as List)
          .map(BuddyWorktree.fromJson)
          .toList(),
    );
  }
}

class BuddyWorktree {
  const BuddyWorktree({
    required this.name,
    required this.path,
    required this.available,
  });

  final String name;
  final String path;
  final bool available;

  factory BuddyWorktree.fromJson(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['name'] is! String ||
        value['path'] is! String ||
        value['available'] is! bool) {
      throw const FormatException('Worktree response has an invalid shape.');
    }
    return BuddyWorktree(
      name: value['name'] as String,
      path: value['path'] as String,
      available: value['available'] as bool,
    );
  }
}

class BuddyCommand {
  const BuddyCommand({
    required this.id,
    required this.project,
    required this.command,
    required this.status,
    this.error,
  });

  final String id;
  final String project;
  final String command;
  final String status;
  final String? error;
}

class BuddyStatus {
  const BuddyStatus({required this.commands, required this.tasks});
  final List<BuddyCommand> commands;
  final List<AgentTask> tasks;
}

class BuddyApiException implements Exception {
  const BuddyApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class BuddyApi {
  BuddyApi({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  static const _shortTimeout = Duration(seconds: 12);
  static const _commandTimeout = Duration(minutes: 4);

  Uri _endpoint(String path) {
    final base = ApiConfig.serverBaseUrl.trim().replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    final uri = Uri.tryParse('$base$path');
    if (base.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const BuddyApiException(
        'BUDDY_SERVER_URL is not a valid server address.',
      );
    }
    return uri;
  }

  Future<dynamic> _request(
    String path, {
    String? body,
    Duration timeout = _shortTimeout,
  }) async {
    try {
      final uri = _endpoint(path);
      final response = body == null
          ? await _client.get(uri).timeout(timeout)
          : await _client
                .post(
                  uri,
                  headers: const {'Content-Type': 'application/json'},
                  body: body,
                )
                .timeout(timeout);
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const BuddyApiException(
          'The Buddy server returned malformed JSON.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final detail =
            decoded is Map<String, dynamic> && decoded['detail'] is String
            ? decoded['detail'] as String
            : 'HTTP ${response.statusCode}';
        throw BuddyApiException(detail);
      }
      return decoded;
    } on BuddyApiException {
      rethrow;
    } on TimeoutException {
      throw const BuddyApiException(
        'The Buddy server timed out. Check that it is running and try again.',
      );
    } on http.ClientException catch (error) {
      throw BuddyApiException(
        'Could not connect to the Buddy server: ${error.message}',
      );
    } on FormatException {
      throw const BuddyApiException(
        'The Buddy server returned malformed data.',
      );
    } catch (error) {
      throw BuddyApiException('Could not reach the Buddy server: $error');
    }
  }

  Future<List<BuddyProject>> getProjects() async {
    final body = await _request('/projects');
    if (body is! Map<String, dynamic> || body['projects'] is! List) {
      throw const BuddyApiException(
        'The Buddy server returned a malformed projects response.',
      );
    }
    try {
      return (body['projects'] as List).map(BuddyProject.fromJson).toList();
    } on FormatException catch (error) {
      throw BuddyApiException(
        'The Buddy server returned malformed project data: ${error.message}',
      );
    }
  }

  Future<({String commandId, List<AgentTask> tasks})> sendCommand(
    String project,
    String command,
  ) async {
    final body = await _request(
      '/command',
      body: jsonEncode({'project': project, 'command': command}),
      timeout: _commandTimeout,
    );
    if (body is! Map<String, dynamic> ||
        body['command_id'] is! String ||
        body['tasks'] is! List) {
      throw const BuddyApiException(
        'The Buddy server returned a malformed command response.',
      );
    }
    try {
      return (
        commandId: body['command_id'] as String,
        tasks: (body['tasks'] as List)
            .map((task) => AgentTask.fromJson(task as Map<String, dynamic>))
            .toList(),
      );
    } on (FormatException, TypeError) catch (error) {
      throw BuddyApiException(
        'The Buddy server returned malformed task data: $error',
      );
    }
  }

  Future<BuddyStatus> getStatus() async {
    final body = await _request('/status');
    if (body is! Map<String, dynamic> ||
        body['commands'] is! List ||
        body['tasks'] is! List) {
      throw const BuddyApiException(
        'The Buddy server returned a malformed status response.',
      );
    }
    try {
      final commands = (body['commands'] as List).map((item) {
        if (item is! Map<String, dynamic> ||
            item['id'] is! String ||
            item['project'] is! String ||
            item['command'] is! String ||
            item['status'] is! String) {
          throw const FormatException('Invalid command status entry.');
        }
        return BuddyCommand(
          id: item['id'] as String,
          project: item['project'] as String,
          command: item['command'] as String,
          status: item['status'] as String,
          error: item['error'] is String ? item['error'] as String : null,
        );
      }).toList();
      final tasks = (body['tasks'] as List).map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid task status entry.');
        }
        return AgentTask.fromJson(item);
      }).toList();
      return BuddyStatus(commands: commands, tasks: tasks);
    } on (FormatException, TypeError) catch (error) {
      throw BuddyApiException(
        'The Buddy server returned malformed status data: $error',
      );
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
