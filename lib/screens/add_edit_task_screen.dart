import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart'; // This exports Task and TaskType too

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  TaskType _selectedType = TaskType.todo;
  bool _isSaving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedType = widget.task?.type ?? TaskType.todo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete task',
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
              autofocus: !isEditing,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descController,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description (optional)',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Type selector
            DropdownButtonFormField<TaskType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: TaskType.todo,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Todo'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: TaskType.note,
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 20),
                      SizedBox(width: 8),
                      Text('Note'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveTask,
              icon: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.save),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_isSaving ? 'Saving...' : 'Save Task'),
              ),
            ),

            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Cancel'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    bool success;

    if (isEditing) {
      // Update existing task
      final updatedTask = widget.task!.copyWith(
        title: title,
        description: description,
        type: _selectedType,
      );
      success = await provider.updateTask(updatedTask);
    } else {
      // Create new task
      final newTask = Task.create(
        title: title,
        description: description,
        type: _selectedType,
      );
      success = await provider.addTask(newTask);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Task updated' : 'Task created'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save task'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this task?',
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

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      final provider = context.read<TaskProvider>();
      final success = await provider.deleteTask(widget.task!.id);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Task deleted' : 'Failed to delete task'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}