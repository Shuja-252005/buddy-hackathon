part of '../main.dart';

class BuddyHome extends StatefulWidget {
  const BuddyHome({super.key, this.api});
  final BuddyApi? api;
  @override
  State<BuddyHome> createState() => _BuddyHomeState();
}

class _BuddyHomeState extends State<BuddyHome> {
  bool _authenticated = false;
  bool _signUp = false;
  bool _projects = true;
  late final BuddyApi _api;
  late final bool _ownsApi;
  bool _projectsLoading = true;
  bool _serverConnected = false;
  String? _projectsError;
  List<BuddyProject> _availableProjects = [];
  BuddyProject? _selectedProject;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<Exchange> _exchanges = [];
  AgentTask? _selected;
  Timer? _pollTimer;
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? BuddyApi();
    _ownsApi = widget.api == null;
    _loadProjects();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    if (_ownsApi) _api.close();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _projectsLoading = true;
      _projectsError = null;
    });
    try {
      final projects = await _api.getProjects();
      if (!mounted) return;
      setState(() {
        _availableProjects = projects;
        _projectsLoading = false;
        _serverConnected = true;
        _selectedProject = projects
            .where((p) => p.availableWorktreeCount > 0)
            .firstOrNull;
      });
    } on BuddyApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _projectsLoading = false;
        _projectsError = error.message;
        _serverConnected = false;
      });
    }
  }

  void _selectProject(BuddyProject project) {
    setState(() {
      _selectedProject = project;
      _projects = false;
      _exchanges.clear();
    });
    _pollStatus();
    _ensurePolling();
  }

  Future<void> _send([String? value]) async {
    final message = (value ?? _input.text).trim();
    final project = _selectedProject;
    if (message.isEmpty || project == null) return;
    final exchange = Exchange(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      message: message,
      reply: 'Planning tasks with Gemma…',
      tasks: [],
      isPlanning: true,
      isSending: true,
    );
    setState(() {
      _exchanges.add(exchange);
      _input.clear();
    });
    _ensurePolling();
    _scrollToBottom();
    try {
      final result = await _api.sendCommand(project.name, message);
      if (!mounted) return;
      setState(() {
        exchange.id = result.commandId;
        exchange.isSending = false;
        exchange.isPlanning = false;
        exchange.tasks
          ..clear()
          ..addAll(result.tasks);
        exchange.reply = result.tasks.isEmpty
            ? 'Gemma did not create any agent tasks.'
            : 'Gemma delegated ${result.tasks.length} ${result.tasks.length == 1 ? 'task' : 'tasks'} to your coding agents.';
      });
      _pollStatus();
      _ensurePolling();
      _scrollToBottom();
    } on BuddyApiException catch (error) {
      if (!mounted) return;
      setState(() {
        exchange.isSending = false;
        exchange.isPlanning = false;
        exchange.reply = 'Could not send command: ${error.message}';
        _serverConnected = false;
      });
    }
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  void _ensurePolling() {
    final active = _exchanges.any(
      (exchange) =>
          exchange.isSending ||
          exchange.isPlanning ||
          exchange.tasks.any(
            (task) =>
                task.status == AgentStatus.queued ||
                task.status == AgentStatus.running,
          ),
    );
    if (active && _pollTimer == null) {
      _pollTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _pollStatus(),
      );
    } else if (!active) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  Future<void> _pollStatus() async {
    if (_polling || _selectedProject == null) return;
    _polling = true;
    try {
      final snapshot = await _api.getStatus();
      if (!mounted) return;
      setState(() {
        _serverConnected = true;
        final projectName = _selectedProject!.name;
        for (final command in snapshot.commands.where(
          (item) => item.project == projectName,
        )) {
          var exchange = _exchanges
              .where((item) => item.id == command.id)
              .firstOrNull;
          exchange ??= _exchanges
              .where(
                (item) => item.isSending && item.message == command.command,
              )
              .firstOrNull;
          if (exchange == null) {
            exchange = Exchange(
              id: command.id,
              message: command.command,
              reply: '',
              tasks: [],
            );
            _exchanges.add(exchange);
          }
          exchange.id = command.id;
          exchange.isSending = false;
          exchange.isPlanning = command.status == 'planning';
          if (command.status == 'failed' && command.error != null) {
            exchange.reply = 'Command failed: ${command.error}';
          }
          final tasks = snapshot.tasks
              .where((task) => task.commandId == command.id)
              .toList();
          for (final task in tasks) {
            final old = exchange.tasks
                .where((item) => item.id == task.id)
                .firstOrNull;
            if (old == null) {
              exchange.tasks.add(task);
            } else {
              old.status = task.status;
              old.output = task.output;
            }
          }
          if (exchange.reply.isEmpty && tasks.isNotEmpty) {
            exchange.reply =
                'Gemma delegated ${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'} to your coding agents.';
          }
          if (exchange.reply.isEmpty && exchange.isPlanning) {
            exchange.reply = 'Gemma is planning agent tasks…';
          }
        }
        _ensurePolling();
      });
    } on BuddyApiException {
      if (mounted) setState(() => _serverConnected = false);
    } finally {
      _polling = false;
    }
  }

  void _update(VoidCallback callback) => setState(callback);

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Column(
                  children: [
                    if (!_authenticated)
                      _authScreen(safe.top, safe.bottom)
                    else ...[
                      _StatusBar(top: safe.top),
                      if (_projects)
                        _projectScreen(safe.bottom)
                      else
                        _chatScreen(0, safe.bottom),
                    ],
                  ],
                ),
                if (_authenticated && !_projects && _selected != null)
                  _AgentSheet(
                    task: _selected!,
                    onClose: () => setState(() => _selected = null),
                    onStop: () => setState(() => _selected = null),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
