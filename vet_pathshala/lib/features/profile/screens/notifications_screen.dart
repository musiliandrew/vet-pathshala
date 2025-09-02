import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _quizReminders = true;
  bool _achievementAlerts = true;
  bool _newContentAlerts = true;
  bool _studyStreakReminders = true;
  bool _coinUpdates = true;
  bool _socialUpdates = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  String _reminderTime = '9:00 AM';
  String _streakReminderTime = '7:00 PM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: UnifiedTheme.backgroundColor,
        foregroundColor: UnifiedTheme.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveNotificationSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: UnifiedTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection('Learning Reminders', [
              _buildSwitchTile(
                'Quiz Reminders',
                'Daily reminders to take practice quizzes',
                Icons.quiz,
                _quizReminders,
                (value) => setState(() => _quizReminders = value),
              ),
              if (_quizReminders)
                _buildTimeTile(
                  'Reminder Time',
                  'When to receive quiz reminders',
                  Icons.schedule,
                  _reminderTime,
                  () => _selectTime(context, _reminderTime, (time) => setState(() => _reminderTime = time)),
                ),
              _buildSwitchTile(
                'Study Streak Reminders',
                'Reminders to maintain your daily streak',
                Icons.local_fire_department,
                _studyStreakReminders,
                (value) => setState(() => _studyStreakReminders = value),
              ),
              if (_studyStreakReminders)
                _buildTimeTile(
                  'Streak Reminder Time',
                  'Evening reminder to complete daily goal',
                  Icons.schedule,
                  _streakReminderTime,
                  () => _selectTime(context, _streakReminderTime, (time) => setState(() => _streakReminderTime = time)),
                ),
            ]),

            const SizedBox(height: 24),

            _buildNotificationSection('Updates & Achievements', [
              _buildSwitchTile(
                'Achievement Alerts',
                'Notifications when you earn badges',
                Icons.military_tech,
                _achievementAlerts,
                (value) => setState(() => _achievementAlerts = value),
              ),
              _buildSwitchTile(
                'New Content Alerts',
                'Notifications for new notes and quizzes',
                Icons.new_releases,
                _newContentAlerts,
                (value) => setState(() => _newContentAlerts = value),
              ),
              _buildSwitchTile(
                'Coin Updates',
                'Notifications for coin transactions',
                Icons.monetization_on,
                _coinUpdates,
                (value) => setState(() => _coinUpdates = value),
              ),
              _buildSwitchTile(
                'Social Updates',
                'Quiz battles and friend activities',
                Icons.people,
                _socialUpdates,
                (value) => setState(() => _socialUpdates = value),
              ),
            ]),

            const SizedBox(height: 24),

            _buildNotificationSection('Delivery Methods', [
              _buildSwitchTile(
                'Push Notifications',
                'In-app notifications',
                Icons.notifications,
                _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
              ),
              _buildSwitchTile(
                'Email Notifications',
                'Weekly progress reports via email',
                Icons.email,
                _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
              ),
            ]),

            const SizedBox(height: 24),

            // Test Notification Button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendTestNotification,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UnifiedTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: UnifiedTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: UnifiedTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: UnifiedTheme.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: UnifiedTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: UnifiedTheme.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: UnifiedTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String title, String subtitle, IconData icon, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: UnifiedTheme.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: UnifiedTheme.blueAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: UnifiedTheme.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: UnifiedTheme.tertiaryText,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, String currentTime, Function(String) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: UnifiedTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = picked.format(context);
      onTimeSelected(formattedTime);
    }
  }

  void _sendTestNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔔 Test notification sent!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _saveNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved!'),
        backgroundColor: UnifiedTheme.primaryGreen,
      ),
    );
    Navigator.pop(context);
  }
}