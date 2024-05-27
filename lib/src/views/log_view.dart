import 'package:flutter/material.dart';

class LogView extends StatelessWidget {
  const LogView({super.key}); // 使用 super 参数

  @override
  Widget build(BuildContext context) {
    const String logContent = '这里是日志文件的内容'; // 使用 const

    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描日志'), // 使用 const
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(logContent), // 使用 const
      ),
    );
  }
}