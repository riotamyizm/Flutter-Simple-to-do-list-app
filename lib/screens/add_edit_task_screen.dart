import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController title;
  late TextEditingController desc;
  TaskType type = TaskType.todo;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.task?.title ?? '');
    desc = TextEditingController(text: widget.task?.description ?? '');
    type = widget.task?.type ?? TaskType.todo;
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Tambah Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Masukkan judul task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: desc,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<TaskType>(
                isExpanded: true,
                value: type,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: TaskType.todo,
                    child: Text('Todo'),
                  ),
                  DropdownMenuItem(
                    value: TaskType.note,
                    child: Text('Note'),
                  ),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tidak boleh kosong'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final provider = context.read<TaskProvider>();

    if (widget.task == null) {
      provider.addTask(Task(
        id: DateTime.now().toString(),
        title: title.text.trim(),
        description: desc.text.trim(),
        type: type,
      ));
    } else {
      provider.editTask(
        Task(
          id: widget.task!.id,
          title: title.text.trim(),
          description: desc.text.trim(),
          type: type,
          isDone: widget.task!.isDone,
        ),
      );
    }

    Navigator.pop(context);
  }
}
