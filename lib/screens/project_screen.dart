part of '../main.dart';

extension _BuddyProjectScreen on _BuddyHomeState {
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
            onTap: () => _update(() => _projects = false),
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
                          'P.',
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
                          color: const Color(0xFF20242A),
                          border: Border.all(color: const Color(0xFF353B45)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFF8793A3),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Preview mode',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA5B3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'PlaySlot',
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
}
