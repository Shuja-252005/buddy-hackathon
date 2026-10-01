part of '../main.dart';

extension _BuddyChatScreen on _BuddyHomeState {
  Widget _chatScreen(double top, double bottom) => Expanded(
    child: Column(
      children: [
        Container(
          height: 71 + top,
          padding: EdgeInsets.fromLTRB(20, top, 20, 0),
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
                onPressed: () => _update(() => _projects = true),
              ),
              const SizedBox(width: 8),
              Expanded(
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
                      'WORKSPACE / ${_selectedProject?.name.toUpperCase() ?? 'PROJECT'}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFF6D7580),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.circle,
                size: 6,
                color: _serverConnected
                    ? const Color(0xFF8793A3)
                    : const Color(0xFFE08C86),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: 'Server: ${ApiConfig.serverBaseUrl}',
                child: Text(
                  _serverConnected ? 'Connected' : 'Offline',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA8B2BE),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'New conversation',
                onPressed: () => _update(() => _exchanges.clear()),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Attach image',
                              onPressed: () {},
                              icon: const Icon(
                                Icons.image_outlined,
                                size: 19,
                                color: Color(0xFF9BA3AF),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add,
                                size: 21,
                                color: Color(0xFF9BA3AF),
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _input,
                          builder: (_, value, _) => IconButton(
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
}
