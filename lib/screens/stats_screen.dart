import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    // FIXED: Use provider's getters that exclude notes from todo counting
    final totalTodos = provider.totalTasks;
    final totalNotes = provider.totalNotes;
    final completedTodos = provider.completedCount;
    final pendingTodos = provider.pendingCount;
    final percentage = provider.completionPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildStatCard(
              'Total Todos',
              totalTodos.toString(),
              Colors.blue,
              Icons.check_box,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Completed',
              completedTodos.toString(),
              Colors.green,
              Icons.check_circle,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Pending',
              pendingTodos.toString(),
              Colors.orange,
              Icons.hourglass_empty,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Notes',
              totalNotes.toString(),
              Colors.amber,
              Icons.note,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Todo Progress',
              '${percentage.toStringAsFixed(1)}%',
              Colors.purple,
              Icons.trending_up,
            ),
            const SizedBox(height: 32),

            if (totalTodos > 0) ...[
              Text(
                'Todo Completion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completedTodos / totalTodos,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completedTodos == totalTodos ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$completedTodos of $totalTodos todos completed (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              if (totalNotes > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ $totalNotes note${totalNotes != 1 ? 's' : ''} (not counted in progress)',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],

            if (totalTodos == 0 && totalNotes == 0)
              const Padding(
                padding: EdgeInsets.only(top: 80),
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
                color: color.withValues(alpha: 0.2),
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