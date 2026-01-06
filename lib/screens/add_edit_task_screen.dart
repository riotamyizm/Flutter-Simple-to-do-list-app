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
    title = TextEditingController(text: widget.task?.title);
    desc = TextEditingController(text: widget.task?.description);
    type = widget.task?.type ?? TaskType.todo;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
          Text(widget.task == null ? 'Tambah Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration:
              const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: desc,
              maxLines: 4,
              decoration:
              const InputDecoration(labelText: 'Deskripsi'),
            ),
            DropdownButton<TaskType>(
              value: type,
              items: const [
                DropdownMenuItem(
                    value: TaskType.todo, child: Text('Todo')),
                DropdownMenuItem(
                    value: TaskType.note, child: Text('Note')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            ElevatedButton(
              onPressed: () {
                final provider = context.read<TaskProvider>();

                if (widget.task == null) {
                  provider.addTask(Task(
                    id: DateTime.now().toString(),
                    title: title.text,
                    description: desc.text,
                    type: type,
                  ));
                } else {
                  provider.editTask(
                    Task(
                      id: widget.task!.id,
                      title: title.text,
                      description: desc.text,
                      type: type,
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
