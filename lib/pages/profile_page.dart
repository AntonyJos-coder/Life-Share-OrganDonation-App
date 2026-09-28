import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/organ_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final Function(String)? onUsernameChanged;
  
  const ProfilePage({
    super.key,
    this.onUsernameChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController(text: 'Guest User');
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    _isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    // Get current user's email
    final userEmail = authService.currentUser?.email ?? 'Guest User';
    _nameController.text = userEmail;

    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Profile'),
        ),
        body: Consumer<OrganProvider>(
          builder: (context, provider, child) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE53935),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFE53935)),
                    title: Text(_nameController.text),
                    subtitle: const Text('Tap to edit profile'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFFE53935)),
                          onPressed: _editProfile,
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: _editProfile,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.volunteer_activism, color: Color(0xFFE53935)),
                            SizedBox(width: 8),
                            Text(
                              'Your Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Color(0xFFE53935)),
                        title: const Text('Your Donations'),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            provider.donors.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.medical_services, color: Color(0xFFE53935)),
                        title: const Text('Your Requests'),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            provider.requests.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode, color: Color(0xFFE53935)),
                        title: const Text('Dark Mode'),
                        value: _isDarkMode,
                        onChanged: (value) {
                          setState(() => _isDarkMode = value);
                          themeProvider.toggleTheme();
                        },
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_active, color: Color(0xFFE53935)),
                        title: const Text('Notifications'),
                        value: _notificationsEnabled,
                        onChanged: (value) => setState(() => _notificationsEnabled = value),
                      ),
                      ListTile(
                        leading: const Icon(Icons.language, color: Color(0xFFE53935)),
                        title: const Text('Language'),
                        trailing: DropdownButton<String>(
                          value: _selectedLanguage,
                          items: ['English', 'Spanish', 'French']
                              .map((lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedLanguage = value!),
                        ),
                      ),
                      const ListTile(
                        leading: Icon(Icons.help, color: Color(0xFFE53935)),
                        title: Text('Help & Support'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.privacy_tip, color: Color(0xFFE53935)),
                        title: Text('Privacy Policy'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.info, color: Color(0xFFE53935)),
                        title: Text('About'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    try {
                      await context.read<AuthService>().signOut();
                      if (mounted) {
                        Navigator.pop(context); // Close the profile dialog
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              widget.onUsernameChanged?.call(_nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 