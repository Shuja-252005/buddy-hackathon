import 'package:flutter/material.dart';

import 'dart:async';

import 'config/api_config.dart';
import 'models/agent_task.dart';
import 'services/buddy_api.dart';

part 'app.dart';
part 'screens/buddy_home.dart';
part 'screens/project_screen.dart';
part 'screens/chat_screen.dart';
part 'screens/exchange_view.dart';
part 'widgets/agent_sheet.dart';
part 'widgets/buddy_mark.dart';
part 'widgets/status_bar.dart';

void main() => runApp(const BuddyApp());
