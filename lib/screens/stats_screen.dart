import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final done = tasks.where((t) => t.isDone).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Total Task: ${tasks.length}',
              style: const TextStyle(fontSize: 18)),
          Text('Selesai: $done',
              style: const TextStyle(fontSize: 18)),
          Text('Belum Selesai: ${tasks.length - done}',
              style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
