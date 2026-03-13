import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/notification/routes/notification_routes.dart';
import 'package:src/providers/theme_provider.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = AppConstants.languageEnglishString;
  double _textSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _textSize = prefs.getDouble('textSize') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setDouble('textSize', _textSize);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        automaticallyImplyLeading: true,
        centerTitle: false,
        showBottomBorder: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notification settings
              AppNavigator.pushNamed(
                context,
                NotificationRoutes.notificationSettings,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Navigate to help
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildAccountTile(),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildLanguageTile(),
          _buildTextSizeTile(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications',
            Icons.notifications,
            _notificationsEnabled,
            (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
          ),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            'Dark Mode',
            'Enable dark theme',
            Icons.dark_mode,
            _darkMode,
            (value) {
              setState(() => _darkMode = value);
              themeNotifier.toggleTheme();
              _saveSettings();
            },
          ),

          // About Section
          _buildSectionHeader('About'),
          _buildInfoTile('Version', '1.0.0', Icons.info),
          _buildLinkTile('Privacy Policy', Icons.privacy_tip, () {
            AppNavigator.pushNamed(context, AppRoutes.privacyPolicy);
          }),
          _buildLinkTile('Terms of Service', Icons.description, () {
            AppNavigator.pushNamed(context, AppRoutes.termsOfService);
          }),

          const SizedBox(height: 20),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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

  Widget _buildAccountTile() {
    return ListTile(
      leading: const CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
      ),
      title: const Text(
        'John Doe',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('john.doe@example.com'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          // Navigate to edit profile
        },
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: Text(_selectedLanguage),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(),
    );
  }

  Widget _buildTextSizeTile() {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Text Size'),
      subtitle: Slider(
        value: _textSize,
        min: 0.8,
        max: 1.5,
        divisions: 7,
        label: '${(_textSize * 100).round()}%',
        onChanged: (value) {
          setState(() => _textSize = value);
        },
        onChangeEnd: (value) => _saveSettings(),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildLinkTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppConstants.supportedLanguagesFull.length,
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  title: Text(AppConstants.supportedLanguagesFull[index]),
                  value: AppConstants.supportedLanguagesFull[index],
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    _saveSettings();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    final navContext = context;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                navContext.go(AuthRoutes.login);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
