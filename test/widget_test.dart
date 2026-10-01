import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:buddy/main.dart';
import 'package:buddy/services/buddy_api.dart';

void main() {
  testWidgets('loads a project and sends commands to the Buddy API', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final client = MockClient((request) async {
      if (request.url.path == '/projects') {
        return http.Response(
          '''{"projects":[{"name":"PlaySlot","worktrees":[{"name":"agent-admin","path":"/tmp/worktree","available":true,"reason":null}]}]}''',
          200,
        );
      }
      if (request.url.path == '/command') {
        return http.Response(
          jsonEncode({
            'command_id': 'command-1',
            'project': 'PlaySlot',
            'status': 'working',
            'tasks': [
              {
                'id': 'task-1',
                'project': 'PlaySlot',
                'worktree': 'agent-bugs',
                'task': 'Inspect repository structure',
                'status': 'queued',
                'output': List.filled(
                  100,
                  'Captured Codex output line',
                ).join('\n'),
                'started_at': null,
                'completed_at': null,
                'exit_code': null,
                'command_id': 'command-1',
              },
            ],
          }),
          202,
        );
      }
      return http.Response('{"commands":[],"tasks":[]}', 200);
    });

    await tester.pumpWidget(BuddyApp(api: BuddyApi(client: client)));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(ElevatedButton).first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(find.text('PlaySlot'), findsOneWidget);
    expect(find.text('Preview mode'), findsNothing);

    await tester.tap(find.text('PlaySlot'));
    await tester.pumpAndSettle();
    final input = find.byType(TextField);
    await tester.enterText(
      input,
      'Inspect the project layout without changes.',
    );
    await tester.pump();
    final sendButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_upward),
        matching: find.byType(IconButton),
      ),
    );
    expect(sendButton.onPressed, isNotNull);
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    expect(
      find.text('Inspect the project layout without changes.'),
      findsOneWidget,
    );
    expect(find.text('Inspect repository structure'), findsNWidgets(2));
    expect(find.text('Queued'), findsOneWidget);
    await tester.tap(find.text('Inspect repository structure').first);
    await tester.pumpAndSettle();
    expect(find.text('agent output'), findsOneWidget);
    expect(tester.takeException(), isNull);
    client.close();
  });
}
