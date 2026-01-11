import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    // Show loading indicator
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          // Filter button
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter tasks',
            onSelected: (filter) => provider.setFilter(filter),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskFilter.all,
                child: Row(
                  children: [
                    Icon(
                      provider.currentFilter == TaskFilter.all
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('All Tasks'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.pending,
                child: Row(
                  children: [
                    Icon(
                      provider.currentFilter == TaskFilter.pending
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskFilter.completed,
                child: Row(
                  children: [
                    Icon(
                      provider.currentFilter == TaskFilter.completed
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Completed'),
                  ],
                ),
              ),
            ],
          ),

          // Sort button
          PopupMenuButton<TaskSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort tasks',
            onSelected: (sort) => provider.setSort(sort),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskSort.dateDesc,
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: TaskSort.dateAsc,
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: TaskSort.titleAsc,
                child: Text('Title (A-Z)'),
              ),
              const PopupMenuItem(
                value: TaskSort.titleDesc,
                child: Text('Title (Z-A)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                    setState(() {});
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                provider.searchTask(value);
                setState(() {});
              },
            ),
          ),

          // Task summary
          if (provider.totalTasks > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (provider.totalTasks > 0)
                    Text(
                      '${provider.completionPercentage.toStringAsFixed(0)}% complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState(context, provider)
                : RefreshIndicator(
              onRefresh: () => provider.loadTasks(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskTile(
                    key: ValueKey(tasks[index].id),
                    task: tasks[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTask);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskProvider provider) {
    String message;
    String subtitle;
    IconData icon;

    if (provider.totalTasks == 0) {
      icon = Icons.task_alt;
      message = 'No tasks yet';
      subtitle = 'Tap the + button to create your first task';
    } else if (_searchController.text.isNotEmpty) {
      icon = Icons.search_off;
      message = 'No results found';
      subtitle = 'Try a different search term';
    } else {
      icon = Icons.filter_alt_off;
      message = 'No tasks match this filter';
      subtitle = 'Try changing the filter';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}