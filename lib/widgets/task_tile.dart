import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../routes/app_routes.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    // FIXED: Check if this is a note
    final isNote = task.type == TaskType.note;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addTask,
            arguments: task,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED: Show icon for notes, checkbox for todos
              if (isNote)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note,
                    color: Colors.orange,
                    size: 24,
                  ),
                )
              else
                Checkbox(
                  value: task.isDone,
                  onChanged: (value) async {
                    await provider.toggleTask(task.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            task.isDone
                                ? 'Task marked as pending'
                                : 'Task completed!',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              provider.toggleTask(task.id);
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - FIXED: Only strikethrough completed todos, not notes
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: (!isNote && task.isDone)
                            ? TextDecoration.lineThrough
                            : null,
                        color: (!isNote && task.isDone)
                            ? theme.textTheme.bodySmall?.color
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description - FIXED: Only strikethrough completed todos
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: (!isNote && task.isDone)
                              ? TextDecoration.lineThrough
                              : null,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Metadata
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Type badge
                        _buildBadge(
                          context,
                          icon: isNote
                              ? Icons.note
                              : Icons.check_circle_outline,
                          label: isNote ? 'Note' : 'Todo',
                          color: isNote
                              ? Colors.orange
                              : Colors.blue,
                        ),

                        // Date badge
                        _buildBadge(
                          context,
                          icon: Icons.calendar_today,
                          label: dateFormat.format(task.createdAt),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  // FIXED: Only show toggle option for todos, not notes
                  if (!isNote)
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            task.isDone ? Icons.restart_alt : Icons.check,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(task.isDone ? 'Mark Pending' : 'Mark Complete'),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addTask,
                        arguments: task,
                      );
                      break;
                    case 'toggle':
                    // FIXED: Extra safety check
                      if (!isNote) {
                        await provider.toggleTask(task.id);
                      }
                      break;
                    case 'delete':
                      _showDeleteDialog(context, provider);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context,
      TaskProvider provider,
      ) async {
    // FIXED: Different dialog text for notes vs todos
    final isNote = task.type == TaskType.note;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${isNote ? 'Note' : 'Task'}?'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.deleteTask(task.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${isNote ? 'Note' : 'Task'} deleted'
                  : 'Failed to delete ${isNote ? 'note' : 'task'}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}