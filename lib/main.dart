import 'package:flutter/material.dart';
import 'src/views/main_view.dart';
import 'src/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databaseService = DatabaseService();
  await databaseService.initialize(); // 确保在使用前调用 initialize 方法
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({required this.databaseService, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainView(databaseService: databaseService),
    );
  }
}