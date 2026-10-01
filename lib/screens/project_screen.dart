part of '../main.dart';

extension _BuddyProjectScreen on _BuddyHomeState {
  Widget _authScreen(double top, double bottom) => Expanded(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(26, top + 28, 26, 24 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Mark(),
          const SizedBox(height: 16),
          const Text(
            'Buddy.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF303744)),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF26344C), Color(0xFF171B22)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202C40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✦  BUILD BETTER, TOGETHER',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: .8,
                      color: Color(0xFFA9C0F3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your next great idea starts here.',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1.08,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bring your projects and AI coding team into one calm, focused workspace.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Color(0xFF929AA8),
                  ),
                ),
                const SizedBox(height: 21),
                _authFeature(
                  Icons.hub_outlined,
                  'Parallel agents',
                  'Make progress on more, at once',
                ),
                const SizedBox(height: 9),
                _authFeature(
                  Icons.dashboard_outlined,
                  'One clear workspace',
                  'Keep every task in context',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF171A1F),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF30343C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _authTab('Log in', false),
                    const SizedBox(width: 6),
                    _authTab('Sign up', true),
                  ],
                ),
                const SizedBox(height: 17),
                Text(
                  _signUp ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _signUp
                      ? 'Get your workspace ready in a few steps.'
                      : 'Pick up where your team left off.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF858D99),
                  ),
                ),
                if (_signUp) ...[
                  _authField('Your name', 'Alex Morgan'),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 14),
                _authField('Email address', 'you@example.com'),
                const SizedBox(height: 12),
                _authField('Password', 'At least 8 characters', password: true),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () => _update(() {
                      _authenticated = true;
                      _projects = true;
                    }),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(_signUp ? 'Create account' : 'Log in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: const Color(0xFF101622),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Demo UI · Your details won’t be sent or saved',
                    style: TextStyle(fontSize: 9, color: Color(0xFF68717E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'DESIGNED FOR YOUR NEXT BIG IDEA',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: .8,
                color: Color(0xFF525B68),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _authFeature(IconData icon, String title, String subtitle) =>
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xDD171C25),
          border: Border.all(color: const Color(0xFF343E4D)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF29364C),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: const Color(0xFFA7C0F7)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE5E9F0),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8994A5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _authTab(String title, bool signup) => Expanded(
    child: InkWell(
      onTap: () => _update(() => _signUp = signup),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _signUp == signup
              ? const Color(0xFF2A303A)
              : const Color(0xFF101216),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _signUp == signup ? Colors.white : const Color(0xFF848C98),
          ),
        ),
      ),
    ),
  );

  Widget _authField(String title, String hint, {bool password = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFFAEB5C0),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 43,
            child: TextField(
              obscureText: password,
              keyboardType: title == 'Email address'
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF606874),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF101216),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF353A44)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF708BC0)),
                ),
              ),
            ),
          ),
        ],
      );

  Future<void> _showCreateProject() async {
    final name = TextEditingController();
    final folder = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF191C21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Set up a home for your next idea.',
              style: TextStyle(fontSize: 12, color: Color(0xFF8D949F)),
            ),
            const SizedBox(height: 20),
            _authField('Project name', 'e.g. My new app'),
            const SizedBox(height: 14),
            _authField('Project folder', 'Choose a folder or enter its path'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: const Color(0xFF101622),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Demo only · project setup isn’t connected yet',
                style: TextStyle(fontSize: 10, color: Color(0xFF747D89)),
              ),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    folder.dispose();
  }

  Widget _projectScreen(double bottom) => Expanded(
    child: SingleChildScrollView(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR PROJECTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.7,
                  color: Color(0xFF69717D),
                ),
              ),
              Text(
                '${_availableProjects.length.toString().padLeft(2, '0')} / ${_availableProjects.length.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color(0xFF656C76),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _showCreateProject,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: const Color(0xFF101622),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_projectsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_projectsError != null)
            Container(
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
                  const Text(
                    'Backend unavailable',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _projectsError!,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF9CA5B3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadProjects,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_availableProjects.isEmpty)
            const Text(
              'No projects are configured on the Buddy server.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA5B3)),
            )
          else
            ..._availableProjects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: project.availableWorktreeCount == 0
                      ? null
                      : () => _selectProject(project),
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
                                border: Border.all(
                                  color: const Color(0xFF343B49),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${project.name.characters.first}.',
                                style: const TextStyle(
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
                                border: Border.all(
                                  color: const Color(0xFF353B45),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: _serverConnected
                                        ? const Color(0xFF8793A3)
                                        : const Color(0xFFE08C86),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _serverConnected
                                        ? 'Connected'
                                        : 'Unavailable',
                                    style: const TextStyle(
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
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Flutter  ·  Git  ·  ${project.availableWorktreeCount} ${project.availableWorktreeCount == 1 ? 'worktree' : 'worktrees'}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF939AA5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFF30343A), height: 1),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              project.availableWorktreeCount == 0
                                  ? 'No available worktrees'
                                  : 'Open project',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9CB9FC),
                              ),
                            ),
                            const Icon(
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
              ),
            ),
          const SizedBox(height: 44),
          Center(
            child: Text(
              _serverConnected
                  ? 'LOCAL WORKSPACE · READY TO DELEGATE'
                  : 'CONNECT BUDDY SERVER TO DELEGATE',
              style: const TextStyle(
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
