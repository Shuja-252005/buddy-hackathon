part of '../main.dart';

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
