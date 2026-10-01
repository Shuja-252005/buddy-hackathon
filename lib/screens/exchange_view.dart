part of '../main.dart';

extension _BuddyExchangeView on _BuddyHomeState {
  Widget _exchangeView(Exchange exchange, int index) => Padding(
    padding: EdgeInsets.only(bottom: index == _exchanges.length - 1 ? 0 : 36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    exchange.isPlanning
                        ? 'PLANNING AGENT TASKS'
                        : 'DELEGATED TO ${exchange.tasks.length} ${exchange.tasks.length == 1 ? 'AGENT' : 'AGENTS'}',
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
                (t) =>
                    t.status == AgentStatus.completed ||
                    t.status == AgentStatus.failed,
              ))
                _taskResult(task),
              for (final task
                  in exchange.tasks
                      .where(
                        (t) =>
                            t.status == AgentStatus.running ||
                            t.status == AgentStatus.queued,
                      )
                      .take(1))
                _workingLine(task),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _taskCard(AgentTask task) => InkWell(
    onTap: () => _update(() => _selected = task),
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
                            task.title,
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
                      task.worktree,
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
    final color = status == AgentStatus.running
        ? _blue
        : status == AgentStatus.completed
        ? const Color(0xFFA6B9D9)
        : status == AgentStatus.failed
        ? const Color(0xFFE08C86)
        : const Color(0xFF8A8D96);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == AgentStatus.running)
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
            status == AgentStatus.completed
                ? Icons.check
                : status == AgentStatus.failed
                ? Icons.error_outline
                : Icons.schedule,
            size: 12,
            color: color,
          ),
        const SizedBox(width: 5),
        Text(status.label, style: TextStyle(fontSize: 11, color: color)),
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
          task.worktree,
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
              task.status == AgentStatus.queued
                  ? 'Waiting for agent…'
                  : 'Agent is working…',
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
              task.worktree,
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
          task.output.isEmpty
              ? (task.status == AgentStatus.failed
                    ? 'Agent failed${task.exitCode == null ? '' : ' (exit ${task.exitCode})'}.'
                    : 'Agent completed with no output.')
              : _conciseOutput(task.output),
          style: const TextStyle(
            fontSize: 12,
            height: 1.6,
            color: Color(0xFF969FAA),
          ),
        ),
      ],
    ),
  );

  String _conciseOutput(String output) {
    final cleaned = output.trim();
    return cleaned.length > 260 ? '${cleaned.substring(0, 260)}…' : cleaned;
  }
}
