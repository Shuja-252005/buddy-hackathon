import 'dart:async';

import 'package:flutter/material.dart';

const _bg = Color(0xFF0E1013);
const _panel = Color(0xFF181B20);
const _blue = Color(0xFF82A6F6);
const _muted = Color(0xFF858C97);

void main() => runApp(const BuddyApp());

class BuddyApp extends StatelessWidget {
  const BuddyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Buddy',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(primary: _blue, surface: _bg),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: _blue),
    ),
    home: const BuddyHome(),
  );
}

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

class BuddyHome extends StatefulWidget {
  const BuddyHome({super.key});
  @override
  State<BuddyHome> createState() => _BuddyHomeState();
}

class _BuddyHomeState extends State<BuddyHome> {
  bool _projects = false;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<Exchange> _exchanges = [];
  AgentTask? _selected;
  int _nextId = 2;
  Timer? _timer;

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
            worktree: 'buddy_bugfix',
            result: 'Login issue fixed and tests passed.',
          ),
          AgentTask(
            id: 'admin',
            name: 'agent-admin',
            title: 'Update admin dashboard',
            worktree: 'buddy_admin',
            result: 'Admin dashboard updated.',
          ),
        ],
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      setState(() {
        for (final exchange in _exchanges) {
          final task = exchange.tasks
              .where((t) => t.status == AgentStatus.working)
              .firstOrNull;
          if (task != null) {
            if (task.step >= 1) {
              task.step = 2;
              task.status = AgentStatus.completed;
            } else {
              task.step = 1;
            }
            break;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                  ? 'buddy_tests'
                  : isBug
                  ? 'buddy_bugfix'
                  : 'buddy_feature',
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

  Widget _projectScreen(double bottom) => Expanded(
    child: Padding(
      padding: EdgeInsets.fromLTRB(24, 50, 24, 30 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Mark(),
          const SizedBox(height: 30),
          const Text(
            'Buddy.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.8,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your AI development team',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B929D)),
          ),
          const SizedBox(height: 54),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR PROJECTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.7,
                  color: Color(0xFF69717D),
                ),
              ),
              Text(
                '01 / 01',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color(0xFF656C76),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => setState(() => _projects = false),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: '#191c21'.toColor(),
                border: Border.all(color: const Color(0xFF30353C)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF252D3B),
                          border: Border.all(color: const Color(0xFF343B49)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'B.',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFA8C0F7),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202820),
                          border: Border.all(color: const Color(0xFF354235)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFF8CBA90),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Mac Connected',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFA2C9A5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Buddy',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Flutter  ·  Git  ·  3 worktrees',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF939AA5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF30343A), height: 1),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Open project',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CB9FC),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 17,
                        color: Color(0xFF9CB9FC),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Center(
            child: Text(
              'LOCAL WORKSPACE · READY TO DELEGATE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: .4,
                color: Color(0xFF555D68),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _chatScreen(double bottom) => Expanded(
    child: Column(
      children: [
        Container(
          height: 71,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF22252A))),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 40,
                ),
                icon: const Icon(
                  Icons.chevron_left,
                  size: 25,
                  color: Color(0xFFB1B7C1),
                ),
                onPressed: () => setState(() => _projects = true),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buddy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'WORKSPACE / BUDDY',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFF6D7580),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.circle, size: 6, color: Color(0xFF83C397)),
              const SizedBox(width: 6),
              const Text(
                'Connected',
                style: TextStyle(fontSize: 11, color: Color(0xFFA8B2BE)),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'New conversation',
                onPressed: () => setState(() => _exchanges.clear()),
                icon: const Icon(
                  Icons.open_in_new,
                  size: 17,
                  color: Color(0xFF89919D),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _exchanges.isEmpty
              ? _emptyState()
              : ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  children: [
                    for (var i = 0; i < _exchanges.length; i++)
                      _exchangeView(_exchanges[i], i),
                  ],
                ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 13 + bottom),
          decoration: const BoxDecoration(
            color: _bg,
            border: Border(top: BorderSide(color: Color(0xFF1E2227))),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(11, 8, 9, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2127),
                  border: Border.all(color: const Color(0xFF383D46)),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 22,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _input,
                      minLines: 2,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFFF1F2F4),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Message your development team...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF777F8B),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 3,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add,
                            size: 21,
                            color: Color(0xFF9BA3AF),
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _input,
                          builder: (_, value, __) => IconButton(
                            onPressed: value.text.trim().isEmpty ? null : _send,
                            style: IconButton.styleFrom(
                              backgroundColor: value.text.trim().isEmpty
                                  ? const Color(0xFF343A46)
                                  : _blue,
                              foregroundColor: const Color(0xFF101622),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_upward, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AGENTS WORK IN ISOLATED GIT WORKTREES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: .3,
                  color: Color(0xFF5F6875),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Mark(),
          const SizedBox(height: 24),
          const Text(
            'What are we building today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              letterSpacing: -.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Describe a task and let your AI team handle it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.5, color: _muted),
          ),
          const SizedBox(height: 25),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: ['Fix a bug', 'Build a feature', 'Run tests']
                .map(
                  (s) => ActionChip(
                    label: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB8BDC6),
                      ),
                    ),
                    backgroundColor: _panel,
                    side: const BorderSide(color: Color(0xFF30343B)),
                    onPressed: () {
                      _input.text = s;
                      _input.selection = TextSelection.collapsed(
                        offset: s.length,
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );

  Widget _exchangeView(Exchange exchange, int index) => Padding(
    padding: EdgeInsets.only(bottom: index == _exchanges.length - 1 ? 0 : 36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'TODAY  ·  09:41',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  letterSpacing: 1.1,
                  color: Color(0xFF666E79),
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF252A33),
              border: Border.all(color: const Color(0xFF333842)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Text(
              exchange.message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Color(0xFFEDF0F4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 23),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Mark(small: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Buddy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE3E6ED),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2433),
                          border: Border.all(color: const Color(0xFF343B4B)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LEAD',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: Color(0xFF9CB6ED),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exchange.reply,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFFCBD0D8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 44, top: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'DELEGATED TO ${exchange.tasks.length} ${exchange.tasks.length == 1 ? 'AGENT' : 'AGENTS'}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: .9,
                      color: Color(0xFF788394),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Divider(color: Color(0xFF252A32))),
                ],
              ),
              const SizedBox(height: 12),
              for (final task in exchange.tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _taskCard(task),
                ),
              for (final task in exchange.tasks.where(
                (t) => t.status != AgentStatus.working,
              ))
                _taskResult(task),
              for (final task
                  in exchange.tasks
                      .where((t) => t.status == AgentStatus.working)
                      .take(1))
                _workingLine(task),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _taskCard(AgentTask task) => InkWell(
    onTap: () => setState(() => _selected = task),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _panel,
        border: Border.all(color: const Color(0xFF292D33)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF222832),
                  border: Border.all(color: const Color(0xFF303741)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.terminal,
                  size: 17,
                  color: Color(0xFFA3B4D1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE7E9ED),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          size: 15,
                          color: Color(0xFF8B929D),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.name,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFF777E89),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD3D6DC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _status(task.status),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _status(AgentStatus status) {
    final color = status == AgentStatus.working
        ? _blue
        : status == AgentStatus.completed
        ? const Color(0xFFA6B9D9)
        : const Color(0xFF8A8D96);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == AgentStatus.working)
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF7DA4FF),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x99719AFF), blurRadius: 6)],
            ),
          )
        else
          Icon(
            status == AgentStatus.completed ? Icons.check : Icons.stop,
            size: 12,
            color: color,
          ),
        const SizedBox(width: 5),
        Text(
          status == AgentStatus.working
              ? 'Working'
              : status == AgentStatus.completed
              ? 'Completed'
              : 'Stopped',
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }

  Widget _workingLine(AgentTask task) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.only(left: 13),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: Color(0xFF364D74))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.name,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFCBD3E2),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF7DA4FF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              task.step == 0
                  ? (task.id == 'admin'
                        ? 'Updating components...'
                        : 'Inspecting authentication...')
                  : 'Running tests...',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color(0xFF88A8E9),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _taskResult(AgentTask task) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.only(left: 13),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: Color(0xFF3B4F72))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              task.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCBD3E2),
              ),
            ),
            const SizedBox(width: 8),
            _status(task.status),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          task.status == AgentStatus.stopped ? 'Agent stopped.' : task.result,
          style: const TextStyle(
            fontSize: 12,
            height: 1.6,
            color: Color(0xFF969FAA),
          ),
        ),
      ],
    ),
  );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.top});
  final double top;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(29, top + 5, 25, 9),
    child: SizedBox(
      height: 37,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt, size: 15),
              SizedBox(width: 5),
              Icon(Icons.wifi, size: 16),
              SizedBox(width: 5),
              Icon(Icons.battery_full, size: 20),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Mark extends StatelessWidget {
  const _Mark({this.small = false});
  final bool small;
  @override
  Widget build(BuildContext context) => Container(
    width: small ? 32 : 44,
    height: small ? 32 : 44,
    decoration: BoxDecoration(
      color: const Color(0xFF1B2535),
      border: Border.all(color: const Color(0xFF353E50)),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(
      Icons.people_alt_outlined,
      size: small ? 17 : 23,
      color: const Color(0xFF8FB1FF),
    ),
  );
}

class _AgentSheet extends StatelessWidget {
  const _AgentSheet({
    required this.task,
    required this.onClose,
    required this.onStop,
  });
  final AgentTask task;
  final VoidCallback onClose;
  final VoidCallback onStop;
  @override
  Widget build(BuildContext context) {
    final lines = [
      'Inspecting repository...',
      task.id == 'admin'
          ? 'Checking dashboard components...'
          : 'Checking authentication...',
      'Updating files...',
      'Running flutter analyze...',
      task.status == AgentStatus.completed
          ? 'Tests passed.'
          : task.status == AgentStatus.stopped
          ? 'Agent stopped.'
          : 'Running checks...',
    ];
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withValues(alpha: .70),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                28 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF191C21),
                border: Border(top: BorderSide(color: Color(0xFF343941))),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 36,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 23),
                        decoration: BoxDecoration(
                          color: const Color(0xFF515761),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF222B3B),
                            border: Border.all(color: const Color(0xFF374153)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.terminal,
                            size: 19,
                            color: Color(0xFF94B3FA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8D949F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(
                            Icons.close,
                            size: 17,
                            color: Color(0xFFB1B6BF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _meta('Worktree:', task.worktree),
                    const SizedBox(height: 10),
                    _meta('Branch:', task.name),
                    const SizedBox(height: 23),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF101215),
                        border: Border.all(color: const Color(0xFF30343B)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF292D33)),
                              ),
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < 3; i++)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF525960),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const Spacer(),
                                const Text(
                                  'agent output',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Color(0xFF737A86),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < lines.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${i + 1}'.padLeft(2, '0'),
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: Color(0xFF4E617A),
                                          ),
                                        ),
                                        const SizedBox(width: 13),
                                        Expanded(
                                          child: Text(
                                            lines[i],
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              color:
                                                  i == lines.length - 1 &&
                                                      task.status ==
                                                          AgentStatus.completed
                                                  ? const Color(0xFF8FACF2)
                                                  : const Color(0xFFAAB2BF),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (task.status == AgentStatus.working) ...[
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onStop,
                          icon: const Icon(Icons.stop, size: 15),
                          label: const Text(
                            'Stop Agent',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE3E5E8),
                            backgroundColor: const Color(0xFF252930),
                            side: const BorderSide(color: Color(0xFF3C4149)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(String label, String value) => RichText(
    text: TextSpan(
      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      children: [
        TextSpan(
          text: '$label ',
          style: const TextStyle(color: Color(0xFF6D7582)),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(color: Color(0xFFD5D9E1)),
        ),
      ],
    ),
  );
}

extension on String {
  Color toColor() {
    final value = replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
