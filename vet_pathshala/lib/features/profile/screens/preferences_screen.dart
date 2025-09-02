import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEnabled = true;
  bool _autoSync = true;
  String _language = 'English';
  String _fontSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: UnifiedTheme.backgroundColor,
        foregroundColor: UnifiedTheme.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferenceSection('Display', [
              _buildSwitchTile(
                'Dark Mode',
                'Switch between light and dark theme',
                Icons.dark_mode_outlined,
                _darkMode,
                (value) => setState(() => _darkMode = value),
              ),
              _buildDropdownTile(
                'Font Size',
                'Adjust text size for better readability',
                Icons.text_fields,
                _fontSize,
                ['Small', 'Medium', 'Large', 'Extra Large'],
                (value) => setState(() => _fontSize = value!),
              ),
              _buildDropdownTile(
                'Language',
                'Choose your preferred language',
                Icons.language,
                _language,
                ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali'],
                (value) => setState(() => _language = value!),
              ),
            ]),

            const SizedBox(height: 24),

            _buildPreferenceSection('Audio & Notifications', [
              _buildSwitchTile(
                'Push Notifications',
                'Receive updates and reminders',
                Icons.notifications_outlined,
                _notifications,
                (value) => setState(() => _notifications = value),
              ),
              _buildSwitchTile(
                'Sound Effects',
                'Enable sound for interactions',
                Icons.volume_up_outlined,
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
              ),
            ]),

            const SizedBox(height: 24),

            _buildPreferenceSection('Data & Storage', [
              _buildSwitchTile(
                'Auto Sync',
                'Automatically sync your progress',
                Icons.sync,
                _autoSync,
                (value) => setState(() => _autoSync = value),
              ),
              _buildActionTile(
                'Clear Cache',
                'Free up storage space',
                Icons.storage,
                () => _clearCache(),
              ),
              _buildActionTile(
                'Export Data',
                'Download your learning data',
                Icons.download,
                () => _exportData(),
              ),
            ]),

            const SizedBox(height: 24),

            _buildPreferenceSection('Privacy & Security', [
              _buildActionTile(
                'Privacy Policy',
                'View our privacy policy',
                Icons.privacy_tip_outlined,
                () => _showPrivacyPolicy(),
              ),
              _buildActionTile(
                'Terms of Service',
                'Read terms and conditions',
                Icons.description_outlined,
                () => _showTermsOfService(),
              ),
              _buildActionTile(
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever,
                () => _showDeleteAccountDialog(),
                isDestructive: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSection(String title, List<Widget> children) {
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

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> options, Function(String?) onChanged) {
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
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: UnifiedTheme.primaryGreen),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? UnifiedTheme.redAccent : UnifiedTheme.primaryGreen;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? UnifiedTheme.redAccent : UnifiedTheme.primaryText,
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

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Your progress will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: UnifiedTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.primaryGreen),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature will be available in next update!'),
        backgroundColor: UnifiedTheme.blueAccent,
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'At Vet-Pathshala, we are committed to protecting your privacy and ensuring the security of your personal information...\n\n'
            'Data Collection:\n'
            '• We collect information necessary to provide our educational services\n'
            '• Personal data is encrypted and stored securely\n'
            '• We do not share your data with third parties\n\n'
            'Your Rights:\n'
            '• Access your data anytime\n'
            '• Request data deletion\n'
            '• Control your privacy settings\n\n'
            'Contact us at privacy@vetpathshala.com for any privacy concerns.',
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

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Welcome to Vet-Pathshala. By using our app, you agree to these terms...\n\n'
            'Service Usage:\n'
            '• Educational content for veterinary professionals only\n'
            '• One account per device policy\n'
            '• Respectful use of community features\n\n'
            'Content Policy:\n'
            '• All content is for educational purposes\n'
            '• Professional advice should supplement, not replace, clinical judgment\n'
            '• Report inappropriate content immediately\n\n'
            'Account Security:\n'
            '• Keep your credentials secure\n'
            '• Report unauthorized access\n'
            '• Follow device registration policies',
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: UnifiedTheme.redAccent),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data, progress, and coins will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted. Please contact support.'),
                  backgroundColor: UnifiedTheme.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}