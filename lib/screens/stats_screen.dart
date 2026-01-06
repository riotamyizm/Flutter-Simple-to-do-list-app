import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final done = tasks.where((t) => t.isDone).length;
    final pending = tasks.length - done;
    final percentage = tasks.isEmpty ? 0.0 : (done / tasks.length * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildStatCard(
              'Total Tasks',
              tasks.length.toString(),
              Colors.blue,
              Icons.list,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Completed',
              done.toString(),
              Colors.green,
              Icons.check_circle,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Pending',
              pending.toString(),
              Colors.orange,
              Icons.hourglass_empty,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Progress',
              '${percentage.toStringAsFixed(1)}%',
              Colors.purple,
              Icons.trending_up,
            ),
            const SizedBox(height: 32),
            if (tasks.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: done / tasks.length,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    done == tasks.length ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            if (tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Completion: ${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            if (tasks.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No tasks yet. Start adding tasks!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}