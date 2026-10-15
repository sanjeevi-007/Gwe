import 'package:flutter/material.dart';

import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: AppTheme.darkSurface,
            child: ListTile(
              leading: const Icon(Icons.tune_rounded, color: AppTheme.darkPrimary),
              title: const Text('Mode: Mock / Real Puck'),
              subtitle: const Text('Configurable in Milestone 3 & 5'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.darkSurface,
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined, color: AppTheme.darkPrimary),
              title: const Text('Export Data (CSV / JSON)'),
              subtitle: const Text('Offline export via Android share sheet'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.darkSurface,
            child: ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.darkError),
              title: const Text('Delete All Local History'),
              subtitle: const Text('Purges all local SQLite tables'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
