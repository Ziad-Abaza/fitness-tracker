import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../../providers/workout_provider.dart';
import '../../core/app_theme.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('DATA MANAGEMENT'),
          _buildTile(
            icon: Icons.download,
            title: 'EXPORT WORKOUTS (CSV)',
            onTap: _exportData,
          ),
          _buildTile(
            icon: Icons.delete_forever,
            title: 'CLEAR ALL DATA',
            textColor: Colors.red,
            onTap: _confirmClearData,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('NOTIFICATIONS'),
          SwitchListTile(
            title: const Text('DAILY REMINDER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Get notified daily to log your workouts.', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            value: _remindersEnabled,
            activeColor: AppTheme.primary,
            onChanged: (val) async {
              setState(() => _remindersEnabled = val);
              if (val) {
                await NotificationService().scheduleDailyReminder();
              } else {
                await NotificationService().cancelAll();
              }
            },
            secondary: const Icon(Icons.notifications_active, color: AppTheme.primary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('ABOUT'),
          _buildTile(
            icon: Icons.info_outline,
            title: 'VERSION',
            trailing: const Text('1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, VoidCallback? onTap, Color? textColor, Widget? trailing}) {
    return Card(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.textPrimary),
        title: Text(title, style: TextStyle(color: textColor ?? AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportData() async {
    final csvData = await context.read<WorkoutProvider>().exportToCSV();
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/workout_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csvData);
    
    await Share.shareXFiles([XFile(path)], text: 'My Workout Export');
    HapticFeedback.lightImpact();
  }

  Future<void> _confirmClearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('WIPE ALL DATA?'),
        content: const Text('This action cannot be undone. All workout history and routines will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE EVERYTHING', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<WorkoutProvider>().clearAllData();
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared.')));
    }
  }
}
