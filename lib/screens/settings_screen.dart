import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeProvider.isSystemMode
                  ? 'Using system settings'
                  : themeProvider.isDarkMode
                  ? 'Dark theme active'
                  : 'Light theme active',
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: themeProvider.isSystemMode
                  ? null
                  : (value) => themeProvider.toggleTheme(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('Use System Theme'),
            subtitle: const Text('Follow device theme settings'),
            trailing: Switch(
              value: themeProvider.isSystemMode,
              onChanged: (value) {
                if (value) {
                  themeProvider.setSystemTheme();
                } else {
                  themeProvider.toggleTheme(false);
                }
              },
            ),
          ),

          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          ListTile(
            leading: Icon(
              themeProvider.notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            title: const Text('Enable Notifications'),
            subtitle: Text(
              themeProvider.notificationsEnabled
                  ? 'You will receive task reminders'
                  : 'Notifications are disabled',
            ),
            trailing: Switch(
              value: themeProvider.notificationsEnabled,
              onChanged: (value) => themeProvider.toggleNotifications(value),
            ),
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader('Data Management'),

          // Statistics Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Storage Statistics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Total Tasks', taskProvider.totalTasks),
                  _buildStatRow('Completed', taskProvider.completedCount),
                  _buildStatRow('Pending', taskProvider.pendingCount),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: taskProvider.totalTasks == 0
                        ? 0
                        : taskProvider.completedCount / taskProvider.totalTasks,
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.orange),
            title: const Text('Clear Completed Tasks'),
            subtitle: Text('${taskProvider.completedCount} completed tasks'),
            enabled: taskProvider.completedCount > 0,
            onTap: () => _showClearCompletedDialog(context, taskProvider),
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete All Tasks',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: Text('${taskProvider.totalTasks} total tasks'),
            enabled: taskProvider.totalTasks > 0,
            onTap: () => _showDeleteAllDialog(context, taskProvider),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Feedback'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact: support@todoapp.com'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy will be shown here'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Version info
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCompletedDialog(
      BuildContext context,
      TaskProvider provider,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks?'),
        content: Text(
          'This will permanently delete ${provider.completedCount} completed task(s). This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.deleteCompletedTasks();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Completed tasks cleared'
                  : 'Failed to clear tasks',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAllDialog(
      BuildContext context,
      TaskProvider provider,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Tasks?'),
        content: const Text(
          'This will permanently delete ALL your tasks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.clearAllTasks();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'All tasks deleted'
                  : 'Failed to delete tasks',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simple Todo App'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'A simple and intuitive todo list app to help you stay organized and productive.',
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Create and manage tasks'),
              Text('• Search and filter tasks'),
              Text('• View task statistics'),
              Text('• Dark mode support'),
              Text('• Data persistence'),
              SizedBox(height: 16),
              Text(
                'Built with Flutter & Material 3',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}