part of '../main.dart';

class BuddyHome extends StatefulWidget {
  const BuddyHome({super.key});
  @override
  State<BuddyHome> createState() => _BuddyHomeState();
}

class _BuddyHomeState extends State<BuddyHome> {
  bool _projects = true;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<Exchange> _exchanges = [];
  AgentTask? _selected;
  int _nextId = 2;

  @override
  void initState() {
    super.initState();
    _exchanges.add(
      Exchange(
        id: 1,
        message: 'Fix the login bug and update the admin dashboard.',
        reply: "I'll split this into two tasks and run them in parallel.",
        tasks: [
          AgentTask(
            id: 'bugs',
            name: 'agent-bugs',
            title: 'Fix login / authentication issue',
            worktree: 'play_slot_bugfix',
            result: 'Login issue fixed and tests passed.',
          ),
          AgentTask(
            id: 'admin',
            name: 'agent-admin',
            title: 'Update admin dashboard',
            worktree: 'play_slot_admin',
            result: 'Admin dashboard updated.',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? value]) {
    final message = (value ?? _input.text).trim();
    if (message.isEmpty) return;
    final lower = message.toLowerCase();
    final isTest = lower.contains('test');
    final isBug = lower.contains('bug') || lower.contains('fix');
    final name = isTest
        ? 'agent-tests'
        : isBug
        ? 'agent-bugs'
        : 'agent-build';
    setState(() {
      _exchanges.add(
        Exchange(
          id: _nextId++,
          message: message,
          reply: "On it. I've delegated this to a coding agent in its own worktree.",
          tasks: [
            AgentTask(
              id: name,
              name: name,
              title: isTest
                  ? 'Run project tests'
                  : isBug
                  ? 'Investigate and fix issue'
                  : 'Implement requested changes',
              worktree: isTest
                  ? 'play_slot_tests'
                  : isBug
                  ? 'play_slot_bugfix'
                  : 'play_slot_feature',
              result: isTest
                  ? 'Tests completed successfully.'
                  : isBug
                  ? 'Issue fixed and checks passed.'
                  : 'Changes implemented and verified.',
            ),
          ],
        ),
      );
      _input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients)
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
    });
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
                    _StatusBar(top: safe.top),
                    if (_projects)
                      _projectScreen(safe.bottom)
                    else
                      _chatScreen(safe.bottom),
                  ],
                ),
                if (!_projects && _selected != null)
                  _AgentSheet(
                    task: _selected!,
                    onClose: () => setState(() => _selected = null),
                    onStop: () {
                      setState(() {
                        _selected!.status = AgentStatus.stopped;
                        _selected = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
